# LEP Docker

LEP Docker is a Linux, Nginx and PHP (with Node and Composer) Docker image for Laravel-like applications!

**NOT MEANT FOR PRODUCTION USE**

## General Details

- OS: Ubuntu Bionic
- Node 10.x
- PHP 7.3
- Default user for Nginx (www-data)

## How To Use (Sample Dockerfile)

```docker
FROM solucionesgbh/lep:latest

# Copy your App into the /app folder.
COPY . /app

# Composer install.
ENV GITHUB_TOKEN <<the_token>>
RUN composer config --global github-oauth.github.com $GITHUB_TOKEN
RUN composer install --no-interaction

# Install node dependencies if needed (npm, yarn).
RUN npm install
# RUN yarn install

# Create your .env file
COPY .env.example .env

# Run our initialization command.
# It ensures permissions of app folders and executes supervisor for nginx and php-fpm.
CMD ["/run.sh"]
```
