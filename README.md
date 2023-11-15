<!-- omit in toc -->
# Docker images - LEP

- [:page\_facing\_up: Description](#page_facing_up-description)
- [:card\_file\_box: Included dependencies](#card_file_box-included-dependencies)
- [:bookmark\_tabs: Relevant considerations](#bookmark_tabs-relevant-considerations)
- [:dart: How To Use](#dart-how-to-use)
- [:whale2: Build your image](#whale2-build-your-image)
- [:rocket: Run your app](#rocket-run-your-app)

## :page_facing_up: Description

LEP comes from the original `LAMP` stack which was based on **L**inux, **A**pache, **M**ySQL and **P**HP. LEP is a docker-oriented alternative that uses Nginx in favor Apache and separates the MySQL dependency since it can be configured as a service using docker compose.

> **Note**: This image is **not meant for production** use. It was designed to serve as an auxiliary image for development and testing environments.

## :card_file_box: Included dependencies

- Ubuntu Jammy
- Node.js 14.x
- git
- nginx
- PHP (7.4)
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

## :bookmark_tabs: Relevant considerations

- The default user for your web files should be `www-data`. If the permissions of your files are not properly set, you might end up with HTTP 403 errors from the web server.

## :dart: How To Use

To use this image, you should set it as your base image using the `FROM` instruction:

```docker
FROM solucionesgbh/lep:${PHP_VERSION}

# Copy your app into the /app folder
WORKDIR /app
COPY . .

# Install your dependencies
RUN composer install --no-interaction
RUN npm ci

# Configure your environment seetings
COPY --chown=www-data:www-data path/to/your/example/.env .env
COPY --chown=www-data:www-data path/to/your/example/local-config.php local-config.php

# Ensures permissions of the app folder are set to www-data
COPY --chown=www-data:www-data .

# Optional: Specify the supervisord command
# You can just leave this out and it will use the base image default
CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
```

## :whale2: Build your image

To build your custom image, on your terminal execute the following `docker build` command:

```shell
docker build . -t myapp:myversion
```

## :rocket: Run your app

To run your custom container, on your terminal execute the following `docker run` command:

```shell
docker run \
  --name myAppContainer \
  -p "${myPublishedPort}:80" \
  myapp:myversion
```
