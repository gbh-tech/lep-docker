# LEP Docker

LEP comes from the original LAMP stack which was based on Linux, Apache, MySQL and PHP. LEP is a docker-oriented alternative that uses Nginx in favor Apache and separates the MySQL dependency since it can be configured as a service using docker compose.

**Important Note**: This image is not meant for production use. It was designed to serve as an auxiliary image for development and testing environments.

## Included dependencies

- Ubuntu Focal
- Nodejs 14.x
- Git
- Nginx
- PHP (7.3)
  - php-cli
  - php-curl
  - php-dev
  - php-fpm
  - php-gd
  - php-imap
  - php-mbstring
  - php-mysql
  - php-pgsql
  - php-readline
  - php-xml
  - php-zip

## Relevant considerations

- The default user for your web files should be `www-data`. If the permissions of your files are not properly set, you might end up with HTTP 403 errors from the web server.

## How To Use

To use this image, you should set it as your base image using the `FROM` instruction:

```docker
FROM solucionesgbh/lep:7.3-node12

# Copy your app into the /app folder
WORKDIR /app
COPY . .

# Install your dependencies
RUN composer install --no-interaction
RUN npm install

# Configure your environment seetings
COPY path/to/your/example/.env .env
COPY path/to/your/example/local-config.php local-config.php

# Ensures permissions of the app folder are set to www-data
RUN chown -R www-data:www-data .

# Optional: Specify the supervisord command
# You can just leave this out and it will use the base image default
CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
```
