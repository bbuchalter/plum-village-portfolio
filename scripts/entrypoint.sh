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
# Remove the directory that the MariaDB package created at build time,
# then replace it with a symlink into the Fly volume.
rm -rf /var/lib/mysql
ln -sfn "$MYSQL_DATA_DIR" /var/lib/mysql
chown -R mysql:mysql "$MYSQL_DATA_DIR"

# Ensure MariaDB socket directory exists
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

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

# Run the WordPress docker-entrypoint to populate /var/www/html with WP files
# (it's a no-op if files already exist)
echo "Running WordPress entrypoint..."
docker-entrypoint.sh apache2 &>/dev/null &
WP_PID=$!
# Wait for wp-config.php to be created, which signals WP files are ready
until [ -f /var/www/html/wp-config.php ]; do
  sleep 1
done
kill "$WP_PID" 2>/dev/null || true
wait "$WP_PID" 2>/dev/null || true

# Install custom theme and plugins from staging area
echo "Installing custom theme and plugins..."

# Custom theme
if [ -d /usr/src/plum-village-theme ]; then
  cp -r /usr/src/plum-village-theme /var/www/html/wp-content/themes/plum-village
fi

# Custom blocks plugin
if [ -d /usr/src/plum-village-blocks ]; then
  cp -r /usr/src/plum-village-blocks /var/www/html/wp-content/plugins/plum-village-blocks
fi

# LearnDash
if [ -f /usr/src/sfwd-lms.zip ] && [ ! -d /var/www/html/wp-content/plugins/sfwd-lms ]; then
  echo "Installing LearnDash..."
  unzip -q /usr/src/sfwd-lms.zip -d /var/www/html/wp-content/plugins/
fi

# BuddyPress
if [ -f /usr/src/buddypress.zip ] && [ ! -d /var/www/html/wp-content/plugins/buddypress ]; then
  echo "Installing BuddyPress..."
  unzip -q /usr/src/buddypress.zip -d /var/www/html/wp-content/plugins/
fi

# Fix ownership for all wp-content
chown -R www-data:www-data /var/www/html/wp-content

# Re-symlink uploads after WordPress entrypoint may have recreated wp-content
ln -sfn "$UPLOADS_DIR" /var/www/html/wp-content/uploads

echo "Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
