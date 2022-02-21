FROM ubuntu:20.04

LABEL maintainer="GBH DevOps Team <devops@gbh.com.do>"

ARG PHP_VERSION=7.4

ENV DEBIAN_FRONTEND noninteractive
ENV NODE_VERSION 14.x

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# We accept the risk of installing system dependencies with
# apt-get without specifying their versions.
# hadolint ignore=DL3008
RUN apt-get update -yq \
&&  apt-get install --no-install-recommends -yq \
    apt-utils \
    curl \
    software-properties-common \
&&  apt-add-repository ppa:nginx/stable -y \
&&  apt-add-repository ppa:ondrej/php -y \
&&  curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
&&  apt-get update -yq \
&&  apt-get install --no-install-recommends -yq \
    build-essential \
    git \
    locales  \
    nginx  \
    nodejs \
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
    vim \
&&  locale-gen en_US.UTF-8 \
&&  dpkg-reconfigure locales \
&&  mkdir -p /run/php \
&&  update-alternatives --set php /usr/bin/php${PHP_VERSION} \
&&  update-alternatives --set php-config /usr/bin/php-config${PHP_VERSION} \
&&  update-alternatives --set phpize /usr/bin/phpize${PHP_VERSION} \
&&  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHP_VERSION}/fpm/php.ini \
&&  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHP_VERSION}/fpm/php.ini \
&&  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/${PHP_VERSION}/fpm/php.ini \
&&  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${PHP_VERSION}/fpm/php.ini \
&&  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/${PHP_VERSION}/fpm/php.ini \
&&  sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/${PHP_VERSION}/fpm/php.ini \
&&  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/${PHP_VERSION}/fpm/php.ini \
&&  rm /etc/nginx/sites-enabled/default \
&&  rm /etc/nginx/sites-available/default \
&&  rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3022
COPY --from=composer:1.10 /usr/bin/composer /usr/bin/composer

COPY nginx/site.conf /etc/nginx/sites-enabled/site.conf
COPY supervisor /etc/supervisor/conf.d

# PHP_VERSION is an ARG, even if 7.4 is the default we want
# to make sure we use the specified version here.
RUN sed -i "s/7.4/${PHP_VERSION}/" /etc/nginx/sites-enabled/site.conf \
&&  sed -i "s/7.4/${PHP_VERSION}/" /etc/supervisor/conf.d/php-fpm.conf

WORKDIR /usr/app

EXPOSE 80

CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
