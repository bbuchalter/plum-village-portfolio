#!/usr/bin/env bash
set -euo pipefail

UPLOADS_DIR="/data/uploads"

mkdir -p "$UPLOADS_DIR"
ln -sfn "$UPLOADS_DIR" /var/www/html/wp-content/uploads
chown -R www-data:www-data "$UPLOADS_DIR"

# Railway's runtime enables mpm_event alongside mpm_prefork — disable it
rm -f /etc/apache2/mods-enabled/mpm_event.*
rm -f /etc/apache2/mods-enabled/mpm_worker.*

# Generates wp-config.php from WORDPRESS_DB_* env vars, then exec's "$@"
exec docker-entrypoint.sh "$@"
