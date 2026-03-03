#!/usr/bin/env bash
set -euo pipefail

if [ -f .env ]; then
  [ -z "${WP_ADMIN_PASSWORD:-}" ] && WP_ADMIN_PASSWORD=$(grep '^WP_ADMIN_PASSWORD=' .env | cut -d= -f2-)
  [ -z "${MYSQL_PUBLIC_URL:-}" ] && MYSQL_PUBLIC_URL=$(grep '^MYSQL_PUBLIC_URL=' .env | cut -d= -f2-)
fi

if [ ! -f data/seed.sql ]; then
  echo "Error: data/seed.sql not found. Run 'make export' first."
  exit 1
fi

if [ -z "${WP_ADMIN_PASSWORD:-}" ]; then
  echo "Error: WP_ADMIN_PASSWORD not set in .env"
  exit 1
fi

if [ -z "${MYSQL_PUBLIC_URL:-}" ]; then
  echo "Error: MYSQL_PUBLIC_URL not set in .env"
  exit 1
fi

PROD_URL="https://plum-village-portfolio.buchalter.dev"

# Parse MySQL URL: mysql://user:password@host:port/database
DB_USER=$(echo "$MYSQL_PUBLIC_URL" | sed -E 's|mysql://([^:]+):.*|\1|')
DB_PASS=$(echo "$MYSQL_PUBLIC_URL" | sed -E 's|mysql://[^:]+:([^@]+)@.*|\1|')
DB_HOST=$(echo "$MYSQL_PUBLIC_URL" | sed -E 's|mysql://[^@]+@([^:]+):.*|\1|')
DB_PORT=$(echo "$MYSQL_PUBLIC_URL" | sed -E 's|mysql://[^@]+@[^:]+:([0-9]+)/.*|\1|')
DB_NAME=$(echo "$MYSQL_PUBLIC_URL" | sed -E 's|mysql://[^@]+@[^/]+/(.+)|\1|')

echo "Importing database via direct MySQL connection..."
docker compose exec -T db mariadb \
  --host="$DB_HOST" \
  --port="$DB_PORT" \
  --user="$DB_USER" \
  --password="$DB_PASS" \
  --skip-ssl \
  "$DB_NAME" < data/seed.sql

echo "Rewriting URLs..."
railway ssh -s wordpress -- wp search-replace 'http://localhost:8000' "$PROD_URL" --all-tables --path=/var/www/html --allow-root

echo "Resetting production admin credentials..."
railway ssh -s wordpress -- wp user update 1 --user_email=bal711@gmail.com --user_pass="${WP_ADMIN_PASSWORD}" --path=/var/www/html --allow-root

echo "Import complete!"
