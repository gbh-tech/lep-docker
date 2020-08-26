FROM ubuntu:bionic

# Maintainer
LABEL maintainer="Angel Adames <a.adames@gbh.com.do>"

# Environment
ENV DEBIAN_FRONTEND noninteractive
ENV PHP_VERSION 7.3

# Update package list and upgrade available packages
RUN apt update &&\
    apt upgrade -y && \
    apt install -y \
      software-properties-common \
      ca-certificates \
      curl

# Add PPAs and repositories
RUN apt-add-repository ppa:nginx/stable -y && \
    apt-add-repository ppa:ondrej/php -y && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash -

# Update package lists again
RUN apt update && \
    apt install --fix-missing -y \
      apt-utils \
      bash-completion \
      build-essential \
      cifs-utils \
      curl \
      git \
      libmcrypt4 \
      libpcre3-dev \
      libpng-dev \
      mcrypt \
      nginx \
      nodejs \
      software-properties-common \
      supervisor \
      vim \
      yarn

# Configure locale and timezone
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# PHP and PHP dependencies installation
RUN apt install -y \
    --allow-downgrades \
    --allow-remove-essential \
    --allow-change-held-packages \
    php-pear \
    php-xdebug \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-dev \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-imap \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-ldap \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-memcached \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-pgsql \
    php${PHP_VERSION}-readline \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip

# Update package alternatives
RUN update-alternatives --set php /usr/bin/php${PHP_VERSION} && \
  update-alternatives --set php-config /usr/bin/php-config${PHP_VERSION} && \
  update-alternatives --set phpize /usr/bin/phpize${PHP_VERSION}

# Install Composer package manager
RUN curl -sS https://getcomposer.org/installer | php && \
  mv composer.phar /usr/local/bin/composer

# PHP CLI & FPM configuration
RUN sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHP_VERSION}/cli/php.ini && \
    sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/${PHP_VERSION}/cli/php.ini && \
    sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHP_VERSION}/cli/php.ini && \
    sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${PHP_VERSION}/cli/php.ini && \
    sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    echo "xdebug.remote_enable = 1" >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini && \
    echo "xdebug.remote_connect_back = 1" >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini && \
    echo "xdebug.remote_port = 9000" >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini && \
    echo "xdebug.max_nesting_level = 512" >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini && \
    echo "opcache.revalidate_freq = 0" >> /etc/php/${PHP_VERSION}/mods-available/opcache.ini

# Remove Nginx default configuration file
RUN rm /etc/nginx/sites-enabled/default && \
    rm /etc/nginx/sites-available/default

# Add OpenSSL certificate authority configuration to PHP FPM
RUN printf "[openssl]\n" | tee -a /etc/php/${PHP_VERSION}/fpm/php.ini && \
    printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/${PHP_VERSION}/fpm/php.ini && \
    printf "[curl]\n" | tee -a /etc/php/${PHP_VERSION}/fpm/php.ini && \
    printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/${PHP_VERSION}/fpm/php.ini

# Add nginx and supervisor services configuration
COPY nginx/default /etc/nginx/sites-available
COPY supervisord /etc/supervisor/conf.d

# Enable default nginx configuration
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Install GEOS
WORKDIR /app

RUN curl -s -O http://download.osgeo.org/geos/geos-3.6.1.tar.bz2
RUN tar -xjvf geos-3.6.1.tar.bz2

WORKDIR /app/geos-3.6.1
RUN ./configure --enable-php
RUN make
RUN make install

WORKDIR /app
RUN ldconfig
RUN apt update && apt install wget -y
RUN wget https://git.osgeo.org/gogs/geos/php-geos/archive/master.tar.gz
RUN ls
RUN tar -zxvf master.tar.gz

WORKDIR /app/php-geos
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

# Cleaning
WORKDIR /app
RUN rm * -r

# Clean up image
RUN apt autoremove -y && \
    apt clean -y

# Add run.sh script
COPY scripts/run.sh /run.sh
RUN chmod 755 /run.sh && \
    mkdir -p /run/php

# Set working directory
WORKDIR /app

# Expose default HTTP port
EXPOSE 80

CMD ["/run.sh"]
