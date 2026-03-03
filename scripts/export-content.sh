#!/usr/bin/env bash
set -euo pipefail

echo "Exporting database from local WordPress..."
docker compose run --rm wpcli wp db export /var/www/html/seed.sql

echo "Copying seed.sql to data/ directory..."
mkdir -p data
docker compose cp wordpress:/var/www/html/seed.sql ./data/seed.sql

echo "Export complete: data/seed.sql"
