<!-- omit in toc -->
# gbh.tech - Linux, Nginx PHP (LEP) Docker Image

[![🧪 Tests](https://github.com/gbh-tech/lep-docker/actions/workflows/test.yml/badge.svg)](https://github.com/gbh-tech/lep-docker/actions/workflows/test.yml)
[![🚀 Push](https://github.com/gbh-tech/lep-docker/actions/workflows/push.yml/badge.svg)](https://github.com/gbh-tech/lep-docker/actions/workflows/push.yml)
[![✨ Lint](https://github.com/gbh-tech/lep-docker/actions/workflows/lint.yml/badge.svg)](https://github.com/gbh-tech/lep-docker/actions/workflows/lint.yml)

<!-- omit in toc -->
## Content

- [📄 Description](#-description)
- [🗃️ Included dependencies](#️-included-dependencies)
- [🔖 Relevant considerations](#-relevant-considerations)
- [🎯 How To Use](#-how-to-use)
- [🐳 Build your image](#-build-your-image)
- [🚀 Run your app](#-run-your-app)

## 📄 Description

LEP comes from the original `LAMP` stack which was based on **L**inux,
**A**pache, **M**ySQL and **P**HP. LEP is a docker-oriented alternative
that uses Nginx in favor Apache and separates the MySQL dependency since it
can be configured as a service using docker compose.

> **Note**: This image is **not meant for production** use. It was designed
> to serve as an auxiliary image for development and testing environments.

## 🗃️ Included dependencies

- Ubuntu Jammy
- Node.js 20.x
- Git
- Nginx
- PHP (7.4, 8.0, 8.1)
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

## 🔖 Relevant considerations

- The default user for your web files should be `www-data`.
  If the permissions of your files are not properly set, you might end up
  with HTTP 403 errors from the web server.

## 🎯 How To Use

To use this image, you should set it as your base image using the
`FROM` instruction:

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

## 🐳 Build your image

To build your custom image, on your terminal execute the following `docker build` command:

```shell
docker build . -t myapp:myversion
```

## 🚀 Run your app

To run your custom container, on your terminal execute the following `docker run` command:

```shell
docker run \
  --name myAppContainer \
  -p "${myPublishedPort}:80" \
  myapp:myversion
```
