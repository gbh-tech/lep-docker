# LEP Docker

Linux, Nginx, PHP Docker image for Laravel

## NOT MEANT FOR PRODUCTION USE

## How To Use (Sample Dockerfile)

```docker
FROM solucionesgbh/lep:latest

# Delete sample app
RUN rm -fr /app/*

# Copy our app into the app folder
COPY . /app

# Composer install
ENV GITHUB_TOKEN <<the_token>>
RUN composer config --global github-oauth.github.com $GITHUB_TOKEN
RUN composer install --no-interaction

# NPM install if needed
RUN npm install

# Create our .env file (we use a commited file called .env.staging)
RUN cp .env.staging .env

# Run our command (it runs chmod on our storage and cache folders aswell as php artisan migrate)
CMD ["/run.sh"]
```