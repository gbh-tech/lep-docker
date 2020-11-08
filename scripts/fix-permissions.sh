#!/bin/bash

# Set appropiate permissions to /app
cd /app
chown -R www-data:www-data /app
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
