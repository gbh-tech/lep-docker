FROM ubuntu:trusty

MAINTAINER Ignacio Canó <i.cano@gbh.com.do>

# Install Dependecies
RUN apt-get -y update && \
	apt-get install -y php5-fpm \
	php5-cli \
	php5-common \
	php5-dev \
	php5-memcache \
	php5-imagick \
  	php5-mcrypt \
  	php5-mysql \
  	php5-imap \
  	php5-curl \
  	php-pear \
  	php5-gd \ 
  	nginx \
  	curl \
  	zip \
  	supervisor

# Install node, bower and gulp-cli
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.6/install.sh | bash
ENV NODE_VER v5.12.0
ENV NVM_DIR "/root/.nvm"
RUN [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" \
    && nvm install $NODE_VER \
    && nvm alias default $NODE_VER \
    && nvm use default \
    && npm install -g bower gulp-cli
ENV BASE_NODE_PATH $NVM_DIR/versions/node
ENV NODE_PATH $BASE_NODE_PATH/$NODE_VER/lib/node_modules
ENV PATH $BASE_NODE_PATH/$NODE_VER/bin:$PATH

# Copy confs
COPY nginx/default /etc/nginx/sites-available
COPY supervisord /etc/supervisor/conf.d

# Add our init script
ADD run.sh /run.sh
RUN chmod 755 /run.sh

RUN mkdir /app
WORKDIR /app

EXPOSE 80

CMD ["/run.sh"]