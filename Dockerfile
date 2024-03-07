FROM ubuntu:22.04

LABEL maintainer="GBH DevOps Team <devops@gbh.tech>"

SHELL ["/bin/bash", "-leo", "pipefail", "-c"]

ARG PHP_VERSION=8.1
ARG ASDF_VERSION=0.14.0
ARG NODEJS_VERSION=20

ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# We accept the risk of installing system dependencies with
# apt without specifying their versions.
# hadolint ignore=DL3008,SC1091
RUN apt-get update -yq \
 && apt-get install --no-install-recommends -yq \
      apt-utils \
      curl \
      software-properties-common \
      ca-certificates \
      lsb-release \
      apt-transport-https \
      gnupg2 \
      ca-certificates \
      lsb-release \
      build-essential \
      git \
      locales  \
      ubuntu-keyring \
 && mkdir -p /etc/apt/keyrings \
 && curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | \
      tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null \
 # Install PHP repository
 && add-apt-repository ppa:ondrej/php \
 # Install Nginx repository
 && echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
      http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | \
      tee /etc/apt/sources.list.d/nginx.list \
 && echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | \
      tee /etc/apt/preferences.d/99nginx \
 # Install asdf
 && git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v${ASDF_VERSION} \
 && echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc \
 && . "$HOME/.asdf/asdf.sh" \
 # Install Node.js with asdf
 && asdf plugin add nodejs \
 && asdf install nodejs latest:${NODEJS_VERSION} \
 && asdf global nodejs latest:${NODEJS_VERSION} \
 # Install PHP packages
 && apt-get update -yq \
 && apt-get install --no-install-recommends -yq \
      php${PHP_VERSION}-cli \
      php${PHP_VERSION}-curl \
      php${PHP_VERSION}-dev \
      php${PHP_VERSION}-fpm \
      php${PHP_VERSION}-gd \
      php${PHP_VERSION}-mbstring \
      php${PHP_VERSION}-mysql \
      php${PHP_VERSION}-pgsql \
      php${PHP_VERSION}-readline \
      php${PHP_VERSION}-xml \
      php${PHP_VERSION}-zip \
      supervisor \
      unzip \
      vim \
      nginx \
   && locale-gen en_US.UTF-8 \
   && dpkg-reconfigure locales \
   && mkdir -p /run/php \
   && update-alternatives --set php /usr/bin/php${PHP_VERSION} \
   && update-alternatives --set php-config /usr/bin/php-config${PHP_VERSION} \
   && update-alternatives --set phpize /usr/bin/phpize${PHP_VERSION} \
   # Update php.ini for FPM
   && sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHP_VERSION}/fpm/php.ini \
   && sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHP_VERSION}/fpm/php.ini \
   && sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/${PHP_VERSION}/fpm/php.ini \
   && sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${PHP_VERSION}/fpm/php.ini \
   && sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/${PHP_VERSION}/fpm/php.ini \
   && sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/${PHP_VERSION}/fpm/php.ini \
   && sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/${PHP_VERSION}/fpm/php.ini \
   && apt-get clean && rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3022
COPY --from=composer:2.6.5 /usr/bin/composer /usr/bin/composer

COPY nginx/site.conf /etc/nginx/conf.d/site.conf
COPY supervisor /etc/supervisor/conf.d

# PHP_VERSION is an ARG, even if 8.0 is the default we want
# to make sure we use the specified version here.
RUN sed -i "s/8.0/${PHP_VERSION}/" /etc/nginx/conf.d/site.conf \
 && sed -i "s/8.0/${PHP_VERSION}/g" /etc/supervisor/conf.d/php-fpm.conf

# Fix www-data user in nginx.conf file
RUN sed -i "s/user\s*nginx;/user www-data;/g" /etc/nginx/nginx.conf

WORKDIR /usr/app

EXPOSE 80

CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
