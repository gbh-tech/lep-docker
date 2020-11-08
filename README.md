# LEP Docker

LEP Docker is a Linux, Nginx and PHP (with Node and Composer) Docker image for Laravel-like applications!

> This is image is not production ready. It is advised to only use it on local development environments.

## General details

- OS: Ubuntu Focal
- Node 12.x
- PHP 7.4
- Default user for nginx (www-data)

## How to use

### Sample Dockerfile

```docker
FROM solucionesgbh/lep:7.4

# Copy your App into the /app folder.
COPY . /app

# Composer install.
RUN composer install --no-interaction

# Install node dependencies if needed (npm, yarn).
RUN npm install
# RUN yarn install

# Create your .env file
COPY .env.example .env

# It ensures permissions of app folders and executes supervisor for nginx and php-fpm.
RUN /scripts/fix-permissions.sh
```

### Build & run

To build it:

```shell
docker build . -t myapp:myversion
```

To run it:

```shell
docker run \
  --name myAppContainer \
  -p "${myPublishedPort}:80" \
  myapp:myversion
```
