#!/usr/bin/env bash
set -euo pipefail

# Read WP_ADMIN_PASSWORD from .env (can't source the whole file — other
# values contain spaces/special chars that break bash)
if [ -f .env ] && [ -z "${WP_ADMIN_PASSWORD:-}" ]; then
  WP_ADMIN_PASSWORD=$(grep '^WP_ADMIN_PASSWORD=' .env | cut -d= -f2-)
fi

if [ ! -f data/seed.sql ]; then
  echo "Error: data/seed.sql not found. Run 'make export' first."
  exit 1
fi

if [ -z "${WP_ADMIN_PASSWORD:-}" ]; then
  echo "Error: WP_ADMIN_PASSWORD not set in .env"
  exit 1
fi

echo "Uploading seed.sql to production..."
fly ssh sftp shell <<< "put data/seed.sql /var/www/html/seed.sql"

echo "Importing database..."
fly ssh console -C "wp db import /var/www/html/seed.sql --path=/var/www/html --allow-root"

echo "Rewriting URLs..."
fly ssh console -C "wp search-replace 'http://localhost:8000' 'https://plum-village-portfolio.fly.dev' --all-tables --path=/var/www/html --allow-root"

echo "Resetting production admin credentials..."
fly ssh console -C "wp user update 1 --user_email=bal711@gmail.com --user_pass='${WP_ADMIN_PASSWORD}' --path=/var/www/html --allow-root"

echo "Cleaning up remote seed file..."
fly ssh console -C "rm /var/www/html/seed.sql"

echo "Import complete!"
