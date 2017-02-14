#!/bin/bash
chown -R www-data:www-data /app
chmod -R 777 /app/storage /app/bootstrap/cache
php /app/artisan migrate
exec /usr/bin/supervisord --nodaemon -c /etc/supervisor/supervisord.conf