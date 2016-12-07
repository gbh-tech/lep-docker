#!/bin/bash
composer install
chmod -R 777 storage bootstrap/cache
php artisan migrate
exec /usr/bin/supervisord --nodaemon -c /etc/supervisor/supervisord.conf