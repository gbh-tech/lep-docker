# lep-docker
Linux Nginx PHP docker image for Laravel

*NOT FOR PRODUCTION*

## How to use (Sample Dockerfile)
```
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