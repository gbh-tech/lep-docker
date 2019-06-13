FROM ubuntu:bionic

# Maintainer
LABEL maintainer="Angel Adames <a.adames@gbh.com.do>"

# Environment
ENV DEBIAN_FRONTEND noninteractive

ENV PHP_VERSION 7.2
ENV NODE_VERSION 10.16.0
ENV NVM_VERSION 0.34.0

ENV NVM_DIR /usr/local/nvm

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Update package list and upgrade available packages
RUN apt update; apt upgrade -y

# Add PPAs and repositories
RUN apt install -y \
  software-properties-common \
  ca-certificates \
  curl; \
  apt-add-repository ppa:nginx/stable -y; \
  apt-add-repository ppa:ondrej/php -y; \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -; \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Update package list one more time
RUN apt update

# Update package lists & install some basic packages
RUN apt install --fix-missing -y \
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
  nano \
  software-properties-common \
  supervisor \
  vim \
  yarn \
  zsh

# Configure locale
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale

# Set my timezone
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# User configuration
RUN adduser lep; \
  usermod -p $(echo secret | openssl passwd -1 -stdin) lep

# PHP installation
RUN apt install \
  --allow-downgrades \
  --allow-remove-essential \
  --allow-change-held-packages -y \
  php-pear \
  php-xdebug \
  php${PHP_VERSION}-bcmath \
  php${PHP_VERSION}-cli \
  php${PHP_VERSION}-curl \
  php${PHP_VERSION}-dev \
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

RUN update-alternatives --set php /usr/bin/php${PHP_VERSION}; \
  update-alternatives --set php-config /usr/bin/php-config${PHP_VERSION}; \
  update-alternatives --set phpize /usr/bin/phpize${PHP_VERSION}

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php; \
  mv composer.phar /usr/local/bin/composer
RUN printf "\nPATH=\"/home/lep/.composer/vendor/bin:\$PATH\"\n" | tee -a /home/lep/.profile

# PHP configuration
# Customize PHP CLI configuration
RUN sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHP_VERSION}/cli/php.ini; \
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/${PHP_VERSION}/cli/php.ini; \
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHP_VERSION}/cli/php.ini; \
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${PHP_VERSION}/cli/php.ini

# Install Nginx & PHP-FPM
RUN apt-get install -y \
  --allow-change-held-packages \
  --allow-downgrades \
  --allow-remove-essential \
  nginx \
  php${PHP_VERSION}-fpm

# Remove Nginx default configuration file
RUN rm /etc/nginx/sites-enabled/default; \
  rm /etc/nginx/sites-available/default

RUN sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHP_VERSION}/fpm/php.ini; \
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHP_VERSION}/fpm/php.ini; \
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/${PHP_VERSION}/fpm/php.ini; \
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${PHP_VERSION}/fpm/php.ini; \
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/${PHP_VERSION}/fpm/php.ini; \
  sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/${PHP_VERSION}/fpm/php.ini; \
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/${PHP_VERSION}/fpm/php.ini

RUN printf "[openssl]\n" | tee -a /etc/php/${PHP_VERSION}/fpm/php.ini; \
  printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/${PHP_VERSION}/fpm/php.ini

RUN printf "[curl]\n" | tee -a /etc/php/${PHP_VERSION}/fpm/php.ini; \
  printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/${PHP_VERSION}/fpm/php.ini

# Customize Nginx & PHP-FPM to configured user
RUN sed -i "s/user www-data;/user lep;/" /etc/nginx/nginx.conf; \
  sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf; \
  sed -i "s/user = www-data/user = lep/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf; \
  sed -i "s/group = www-data/group = lep/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

# Add lep user to required groups
RUN usermod -aG sudo lep; usermod -aG www-data lep

# Add NVM to the system
RUN mkdir -p $NVM_DIR; \
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

# Install Node using specified version in the system
RUN . $NVM_DIR/nvm.sh; \
  nvm install $NODE_VERSION; \
  nvm alias default $NODE_VERSION; \
  nvm use default

# Add configuration
COPY nginx/default /etc/nginx/sites-available
COPY supervisord /etc/supervisor/conf.d
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Clean up
RUN apt autoremove -y; \
  apt clean -y

# Add run.sh script
COPY scripts/run.sh /run.sh
RUN chmod 755 /run.sh

# Ensuring permissions are OK
RUN mkdir -p /run/php
RUN chown -R lep:lep /home/lep
WORKDIR /app

EXPOSE 80

CMD ["/run.sh"]
