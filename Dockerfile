FROM ubuntu:bionic

LABEL maintainer="Angel Adames <a.adames@gbh.com.do>"

ENV DEBIAN_FRONTEND noninteractive
ENV PHP_VERSION 7.1
ENV NODE_VERSION v8.11.4
ENV NVM_VERSION 0.33.11

# Install Dependecies
RUN apt-get update && \
  apt-get install -y software-properties-common curl apt-utils && \
  apt-add-repository ppa:ondrej/php -y && \
  apt-get update && \
	apt-get install -y php${PHP_VERSION}-fpm php${PHP_VERSION}-cli php${PHP_VERSION}-dev \
    php${PHP_VERSION}-pgsql php${PHP_VERSION}-sqlite3 php${PHP_VERSION}-gd \
    php${PHP_VERSION}-curl php${PHP_VERSION}-memcached \
    php${PHP_VERSION}-imap php${PHP_VERSION}-mysql php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-xml php${PHP_VERSION}-zip php${PHP_VERSION}-bcmath php${PHP_VERSION}-soap \
    php${PHP_VERSION}-intl php${PHP_VERSION}-readline \
  	nginx zip supervisor git php${PHP_VERSION}-mcrypt

# Enable mcrypt
RUN phpenmod mcrypt


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer


# Install node, bower and gulp-cli
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash
ENV NVM_DIR "/root/.nvm"
RUN [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" \
    && nvm install ${NODE_VERSION} \
    && nvm alias default ${NODE_VERSION} \
    && nvm use default \
    && npm install -g bower gulp-cli
ENV BASE_NODE_PATH $NVM_DIR/versions/node
ENV NODE_PATH $BASE_NODE_PATH/${NODE_VERSION}/lib/node_modules
ENV PATH $BASE_NODE_PATH/${NODE_VERSION}/bin:$PATH


# Confs
RUN mkdir /run/php
COPY nginx/default /etc/nginx/sites-available
COPY supervisord /etc/supervisor/conf.d
RUN sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHP_VERSION}/cli/php.ini && \
    sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHP_VERSION}/cli/php.ini && \
    sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${PHP_VERSION}/cli/php.ini && \
    sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/${PHP_VERSION}/cli/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/max_execution_time = .*/max_execution_time = 300/" /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHP_VERSION}/fpm/php.ini

# Add our init script
ADD run.sh /run.sh
RUN chmod 755 /run.sh

RUN mkdir /app
WORKDIR /app
RUN mkdir /app/public && touch /app/public/index.php && echo '<?php phpinfo();?>' > /app/public/index.php

EXPOSE 80

CMD ["/run.sh"]
