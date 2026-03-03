#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="/data"
MYSQL_DATA_DIR="$DATA_DIR/mysql"
UPLOADS_DIR="$DATA_DIR/uploads"

# Ensure data directories exist
mkdir -p "$MYSQL_DATA_DIR" "$UPLOADS_DIR"

# Symlink uploads into wp-content
ln -sfn "$UPLOADS_DIR" /var/www/html/wp-content/uploads

# Initialize MariaDB data directory if empty
if [ ! -d "$MYSQL_DATA_DIR/mysql" ]; then
  echo "Initializing MariaDB data directory..."
  mariadb-install-db --user=mysql --datadir="$MYSQL_DATA_DIR"
fi

# Point MariaDB at the persistent volume
ln -sfn "$MYSQL_DATA_DIR" /var/lib/mysql
chown -R mysql:mysql "$MYSQL_DATA_DIR"

# Start MariaDB temporarily to create the WordPress database
echo "Starting MariaDB for initial setup..."
mariadbd --user=mysql &
MARIADB_PID=$!

# Wait for MariaDB to be ready
until mariadb -u root -e "SELECT 1" > /dev/null 2>&1; do
  sleep 1
done

# Create WordPress database and user if they don't exist
if [ -z "${WORDPRESS_DB_PASSWORD:-}" ]; then
  echo "Error: WORDPRESS_DB_PASSWORD is not set. Set it via 'fly secrets set'."
  exit 1
fi

mariadb -u root <<-EOSQL
  CREATE DATABASE IF NOT EXISTS wordpress;
  CREATE USER IF NOT EXISTS 'wordpress'@'localhost' IDENTIFIED BY '${WORDPRESS_DB_PASSWORD}';
  ALTER USER 'wordpress'@'localhost' IDENTIFIED BY '${WORDPRESS_DB_PASSWORD}';
  GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';
  FLUSH PRIVILEGES;
EOSQL

# Stop the temporary MariaDB
kill "$MARIADB_PID"
wait "$MARIADB_PID" 2>/dev/null || true

echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
