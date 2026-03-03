# Plum Village Portfolio

WordPress site for Plum Village learning portfolio, deployed on Fly.io.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Fly.io CLI](https://fly.io/docs/flyctl/install/) (for deployment)

## Local Development

```bash
# Start all services (WordPress, MariaDB, Adminer)
make up

# First time only: install WordPress and configure permalinks
make setup

# View logs
make logs

# Stop services
make down
```

- **WordPress**: http://localhost:8000 (admin/admin)
- **Adminer** (DB UI): http://localhost:8080 (server: `db`, user: `wordpress`, password: `wordpress`)

### WP-CLI

Run any WP-CLI command via Make:

```bash
make wp plugin list
make wp theme list
make wp user list
```

## Production Deployment

### First-time setup

```bash
fly apps create plum-village-portfolio
fly volumes create wp_data --region cdg --size 1
fly secrets set WORDPRESS_DB_PASSWORD=$(openssl rand -base64 24)
fly deploy
fly ssh console -C "wp core install \
  --url='https://plum-village-portfolio.fly.dev' \
  --title='Plum Village Portfolio' \
  --admin_user=admin \
  --admin_password=<CHANGE_ME> \
  --admin_email=<YOUR_EMAIL> \
  --path=/var/www/html --allow-root"
fly ssh console -C "wp rewrite structure '/%postname%/' --path=/var/www/html --allow-root"
```

### Subsequent deploys

```bash
make deploy
```

### Architecture notes

The production container runs WordPress + MariaDB in a single Fly.io machine
via supervisord, with a persistent Fly volume mounted at `/data` for the
database and uploads. The entrypoint script initializes MariaDB on first boot,
then delegates to the upstream WordPress docker-entrypoint to populate
`/var/www/html` before handing off to supervisord.

## Content Sync (Local to Production)

```bash
# Export local database
make export

# Import into production (rewrites localhost URLs to fly.dev)
make import-prod
```

## Project Structure

```
├── config/
│   ├── php.ini              # PHP overrides (upload limits, memory)
│   └── supervisord.conf     # Production: Apache + MariaDB process manager
├── scripts/
│   ├── setup.sh             # Local WP install via WP-CLI
│   ├── entrypoint.sh        # Production container entrypoint
│   ├── export-content.sh    # Dump local DB to data/seed.sql
│   └── import-content.sh    # Push DB to Fly.io with URL rewrite
├── docker-compose.yml       # Local dev: WordPress + MariaDB + WP-CLI + Adminer
├── Dockerfile               # Production: WordPress + MariaDB (single container)
├── fly.toml                 # Fly.io configuration
└── Makefile                 # Common commands
```
