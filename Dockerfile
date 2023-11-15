FROM ubuntu:22.04

LABEL maintainer="GBH DevOps Team <devops@gbh.com.do>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG PHP_VERSION=8.1

ENV DEBIAN_FRONTEND noninteractive
ENV NODE_VERSION 20.x

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# We accept the risk of installing system dependencies with
# apt without specifying their versions.
# hadolint ignore=DL3008
RUN apt-get update -yq && \
    apt-get install --no-install-recommends -yq \
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
    ubuntu-keyring && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    add-apt-repository ppa:ondrej/php && \
    curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | \
    tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
    http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | \
    tee /etc/apt/sources.list.d/nginx.list && \
    echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | \
    tee /etc/apt/preferences.d/99nginx && \
    apt-get update -yq && \
    apt-get install --no-install-recommends -yq \
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
    nodejs \
    nginx && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    mkdir -p /run/php && \
    update-alternatives --set php /usr/bin/php${PHP_VERSION} && \
    update-alternatives --set php-config /usr/bin/php-config${PHP_VERSION} && \
    update-alternatives --set phpize /usr/bin/phpize${PHP_VERSION} && \
    sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# hadolint ignore=DL3022
COPY --from=composer:2.6.5 /usr/bin/composer /usr/bin/composer

COPY nginx/site.conf /etc/nginx/conf.d/site.conf
COPY supervisor /etc/supervisor/conf.d

# PHP_VERSION is an ARG, even if 7.4 is the default we want
# to make sure we use the specified version here.
RUN sed -i "s/7.4/${PHP_VERSION}/" /etc/nginx/sites-enabled/site.conf \
&&  sed -i "s/7.4/${PHP_VERSION}/g" /etc/supervisor/conf.d/php-fpm.conf

WORKDIR /usr/app

EXPOSE 80

CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
