FROM ubuntu:focal

# Maintainer
LABEL maintainer="Angel Adames <a.adames@gbh.com.do>"

# Environment
ENV DEBIAN_FRONTEND noninteractive
ENV PHP_VERSION 7.1
ENV NODE_VERSION 14.x

# Update package list and upgrade available packages
RUN apt update && apt upgrade -yq && \
    apt install -yq \
    curl \
    locales \
    software-properties-common

# Add PPAs and repositories
RUN apt-add-repository ppa:nginx/stable -y && \
    apt-add-repository ppa:ondrej/php -y && \
    curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash -

# Update package lists again
RUN apt update && apt install --fix-missing -y \
    build-essential \
    git \
    nginx \
    nodejs \
    supervisor \
    vim

# Configure locale and timezone
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# PHP and PHP dependencies installation
RUN apt install -yq \
    --allow-downgrades \
    --allow-remove-essential \
    --allow-change-held-packages \
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
    php${PHP_VERSION}-zip

# Update package alternatives
RUN update-alternatives --set php /usr/bin/php${PHP_VERSION} && \
    update-alternatives --set php-config /usr/bin/php-config${PHP_VERSION} && \
    update-alternatives --set phpize /usr/bin/phpize${PHP_VERSION}

# Copy Composer binary
COPY --from=composer /usr/bin/composer /usr/bin/composer

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

# Add nginx and supervisor services configuration
RUN rm /etc/nginx/sites-enabled/default && \
    rm /etc/nginx/sites-available/default
COPY nginx/default /etc/nginx/sites-available
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
RUN mkdir -p /run/php
COPY supervisord /etc/supervisor/conf.d

# Clean up image
RUN rm -rf /var/lib/apt/lists/* && \
    apt autoremove -y && \
    apt clean -y

# Set working directory
WORKDIR /app

# Expose default HTTP port
EXPOSE 80

CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
