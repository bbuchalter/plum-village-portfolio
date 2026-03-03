#!/usr/bin/env bash
set -euo pipefail

if [ ! -f data/seed.sql ]; then
  echo "Error: data/seed.sql not found. Run 'make export' first."
  exit 1
fi

echo "Uploading seed.sql to production..."
fly ssh sftp shell <<< "put data/seed.sql /var/www/html/seed.sql"

echo "Importing database..."
fly ssh console -C "wp db import /var/www/html/seed.sql --path=/var/www/html --allow-root"

echo "Rewriting URLs..."
fly ssh console -C "wp search-replace 'http://localhost:8000' 'https://plum-village-portfolio.fly.dev' --all-tables --path=/var/www/html --allow-root"

echo "Cleaning up remote seed file..."
fly ssh console -C "rm /var/www/html/seed.sql"

echo "Import complete!"
