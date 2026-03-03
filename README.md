# Plum Village Portfolio

A WordPress-based learning portfolio for Plum Village, deployed on [Fly.io](https://fly.io). This project demonstrates a complete local-to-production workflow for WordPress using Docker, WP-CLI, and infrastructure-as-code — no manual clicking through dashboards.

## Why WordPress?

The portfolio needs a CMS that supports online learning features (LearnDash), community interaction (BuddyPress), and content management by non-developers. WordPress is the practical choice: it has the plugin ecosystem, and the people who will maintain the content already know it.

The challenge is making WordPress *development* feel modern — version-controlled, reproducible, and deployable from the command line.

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                  Local Development                   │
│                                                      │
│  docker compose up                                   │
│  ┌──────────┐  ┌──────────┐  ┌───────┐  ┌────────┐ │
│  │ WordPress │  │ MariaDB  │  │WP-CLI │  │Adminer │ │
│  │ :8000     │→ │ :3306    │  │(tasks)│  │ :8080  │ │
│  └──────────┘  └──────────┘  └───────┘  └────────┘ │
└─────────────────────────────────────────────────────┘
        │
        │  make export → data/seed.sql → make import-prod
        ▼
┌─────────────────────────────────────────────────────┐
│              Production (Fly.io)                      │
│                                                      │
│  Single container, managed by supervisord            │
│  ┌──────────────────────────────────────────┐       │
│  │           supervisord                     │       │
│  │  ┌──────────┐      ┌──────────┐          │       │
│  │  │  Apache   │  →   │ MariaDB  │          │       │
│  │  │  :80      │      │ :3306    │          │       │
│  │  └──────────┘      └──────────┘          │       │
│  └──────────────────────────────────────────┘       │
│                        │                             │
│  Fly Volume (/data)    │                             │
│  ├── mysql/     ←──────┘ (symlinked)                │
│  └── uploads/       (symlinked to wp-content)       │
└─────────────────────────────────────────────────────┘
```

### Why a single container?

Most WordPress hosting uses two machines — one for the web server, one for the database. For a low-traffic portfolio site, that's unnecessary cost and complexity. Fly.io's smallest VM (shared-cpu-1x, 512MB) runs WordPress + MariaDB comfortably in a single container managed by [supervisord](http://supervisord.org/). The database and uploads live on a persistent Fly volume, so data survives container restarts and redeploys.

This is an intentional trade-off: simplicity and cost over high availability. If the site needed to scale, we'd split the database into a managed service.

### Why Fly.io?

Fly.io runs Docker containers on lightweight VMs close to users. The Paris (`cdg`) region puts the server near Plum Village in France. The free tier and $5/month volume make it viable for a small project, and the `fly` CLI enables fully scripted deployments — no web console needed.

## Local Development

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Fly.io CLI](https://fly.io/docs/flyctl/install/) (for deployment only)

### Getting started

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

After `make setup`, two services are available:

| Service | URL | Credentials |
|---------|-----|-------------|
| WordPress | http://localhost:8000 | admin / admin |
| Adminer (DB UI) | http://localhost:8080 | server: `db`, user: `wordpress`, password: `wordpress` |

### How local dev works

Docker Compose runs four services:

1. **WordPress** (`wordpress:6.9.1-php8.3-apache`) — the web server, mounted to a named volume so WordPress core files persist across restarts
2. **MariaDB** (`mariadb:11`) — the database, also on a named volume
3. **WP-CLI** (`wordpress:cli`) — a disposable container that shares WordPress's volume, used for scripted admin tasks
4. **Adminer** — a lightweight database GUI for inspecting tables directly

The WP-CLI container is the key to the headless workflow. Instead of clicking through the WordPress installer in a browser, `make setup` runs:

```bash
wp core install --url="http://localhost:8000" --title="Plum Village Portfolio" \
  --admin_user=admin --admin_password=admin --admin_email=admin@example.com
wp rewrite structure '/%postname%/'
```

This makes WordPress setup reproducible — anyone can clone the repo, run two commands, and have an identical local environment.

### WP-CLI

Any WP-CLI command can be run through Make:

```bash
make wp plugin list
make wp theme list
make wp user list
make wp post list
```

## Content Pipeline

Content flows one direction: **local → production**. Author content locally, then push it to production when ready.

### Export

```bash
make export
```

This dumps the local database to `data/seed.sql` using WP-CLI's `db export` command.

### Import to production

```bash
make import-prod
```

This script does four things:

1. **Uploads** `data/seed.sql` to the production container via `fly ssh sftp`
2. **Imports** the SQL dump, replacing the entire production database
3. **Rewrites URLs** — WordPress stores absolute URLs in the database (in post content, options, metadata). `wp search-replace` finds every instance of `http://localhost:8000` and replaces it with `https://plum-village-portfolio.fly.dev`
4. **Resets production admin credentials** — since the import overwrites the production database with local data, the admin user reverts to local credentials (admin/admin). The script restores the production email and password from `.env`

### Why full database replacement?

WordPress doesn't have a clean way to merge databases. Content, settings, permalinks, widget configurations, and plugin state are all stored in the same database with auto-incremented IDs and serialized PHP data. A targeted merge would need to handle foreign key relationships, serialized data formats, and potential ID conflicts.

Full replacement is simple and reliable. The trade-off is that production-only changes (like comments or form submissions) get overwritten. For a portfolio site where all content is authored locally, this is acceptable.

## Production Deployment

### First-time setup

```bash
# Create the Fly.io app
fly apps create plum-village-portfolio

# Create a 1GB persistent volume in Paris
fly volumes create wp_data --region cdg --size 1

# Set the database password (the only secret not in the container)
fly secrets set WORDPRESS_DB_PASSWORD=$(openssl rand -base64 24)

# Build and deploy the container
fly deploy

# Install WordPress on production
fly ssh console -C "wp core install \
  --url='https://plum-village-portfolio.fly.dev' \
  --title='Plum Village Portfolio' \
  --admin_user=admin \
  --admin_password=<CHANGE_ME> \
  --admin_email=<YOUR_EMAIL> \
  --path=/var/www/html --allow-root"

# Set human-readable permalink structure
fly ssh console -C "wp rewrite structure '/%postname%/' --path=/var/www/html --allow-root"
```

### Subsequent deploys

```bash
make deploy
```

### The production container

The Dockerfile starts from the official WordPress image and adds MariaDB and supervisord. This deserves some explanation because it's the most non-standard part of the setup.

The official WordPress Docker image has its own entrypoint script (`docker-entrypoint.sh`) that copies WordPress files into `/var/www/html` and generates `wp-config.php`. Since we define a custom `ENTRYPOINT` in our Dockerfile (to initialize MariaDB), we lose that upstream behavior. Our entrypoint must explicitly call the WordPress entrypoint, wait for it to finish populating files, then hand off to supervisord.

The boot sequence (`scripts/entrypoint.sh`):

```
1. Create data directories on Fly volume (/data/mysql, /data/uploads)
2. Symlink uploads into wp-content
3. Initialize MariaDB data directory (first boot only)
4. Symlink /data/mysql → /var/lib/mysql (rm -rf the existing directory first)
5. Start MariaDB temporarily, create database and user
6. Stop MariaDB
7. Run WordPress docker-entrypoint.sh to populate /var/www/html
8. Start supervisord (Apache + MariaDB as long-running processes)
```

### Secrets management

Production secrets are managed separately from the codebase:

- **Database password**: Set via `fly secrets set WORDPRESS_DB_PASSWORD=...` — injected as an environment variable at runtime, never written to disk or committed to git
- **Admin password**: Stored in `.env` (gitignored), used by the import script to reset credentials after a database sync
- **`.env.example`**: Committed as a template showing what variables are needed, without actual values

## Lessons Learned

Building this workflow surfaced several non-obvious issues:

**WordPress stores absolute URLs in the database.** Every link, image src, and site reference is stored as a full URL (e.g., `http://localhost:8000/wp-content/uploads/photo.jpg`). Moving between environments requires a search-replace across the entire database. WP-CLI's `search-replace` command handles this, including serialized PHP data in `wp_options`.

**PHP's `localhost` vs `127.0.0.1` behavior matters.** When `WORDPRESS_DB_HOST` is set to `localhost`, PHP's MySQL driver uses a Unix socket instead of TCP. In a container where the socket path isn't configured, this silently fails with "Error establishing a database connection." Using `127.0.0.1` forces TCP and works reliably.

**Docker entrypoints are inherited, not composed.** Defining a custom `ENTRYPOINT` in a Dockerfile completely replaces the base image's entrypoint. The WordPress image's entrypoint does essential work (copying files, creating wp-config.php), so our custom entrypoint must explicitly invoke it.

**MariaDB's Debian package creates real directories.** `apt-get install mariadb-server` creates `/var/lib/mysql` as a real directory. You can't symlink over a non-empty directory with `ln -sfn` — you must `rm -rf` it first, then create the symlink to the persistent volume.

**Supervisord replaces an init system.** In a normal Linux system, systemd manages services. Containers don't have systemd, so running multiple processes (Apache + MariaDB) requires a process manager. Supervisord fills this role, keeping both processes running and restarting them if they crash.

## Project Structure

```
├── config/
│   ├── php.ini                 # PHP overrides (upload limits, memory)
│   └── supervisord.conf        # Production: Apache + MariaDB process manager
├── scripts/
│   ├── setup.sh                # Local WP install via WP-CLI
│   ├── entrypoint.sh           # Production container boot sequence
│   ├── export-content.sh       # Dump local DB to data/seed.sql
│   └── import-content.sh       # Push DB to Fly.io with URL rewrite
├── docker-compose.yml          # Local dev: WordPress + MariaDB + WP-CLI + Adminer
├── Dockerfile                  # Production: WordPress + MariaDB (single container)
├── fly.toml                    # Fly.io configuration
└── Makefile                    # Common commands
```
