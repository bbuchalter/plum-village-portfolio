#!/usr/bin/env bash
set -euo pipefail

echo "Waiting for WordPress to be ready..."
until docker compose run --rm wpcli wp db check > /dev/null 2>&1; do
  echo "  Database not ready, retrying in 3s..."
  sleep 3
done

echo "Installing WordPress..."
docker compose run --rm wpcli wp core install \
  --url="http://localhost:8000" \
  --title="Plum Village Portfolio" \
  --admin_user=admin \
  --admin_password=admin \
  --admin_email=admin@example.com

echo "Setting permalink structure..."
docker compose run --rm wpcli wp rewrite structure '/%postname%/'

echo "Setup complete! Visit http://localhost:8000"
