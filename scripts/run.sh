#!/bin/bash

chown www-data:www-data -R /app

find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

exec /usr/bin/supervisord --nodaemon -c /etc/supervisor/supervisord.conf
