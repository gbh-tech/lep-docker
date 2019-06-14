#!/bin/bash

chown lep:lep -R /app

cd /app
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

exec /usr/bin/supervisord --nodaemon -c /etc/supervisor/supervisord.conf
