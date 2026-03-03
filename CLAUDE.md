# CLAUDE.md

## Project Overview

WordPress site for Plum Village learning portfolio. Local dev via Docker Compose, production on Fly.io (single container with WordPress + MariaDB via supervisord).

## Key Commands

- `make up` / `make down` — start/stop local dev
- `make setup` — first-time WordPress install (admin/admin)
- `make wp <command>` — run WP-CLI commands (e.g., `make wp plugin list`)
- `make deploy` — deploy to Fly.io
- `make export` / `make import-prod` — content sync (local DB → production)

## Architecture

### Local Development
- **docker-compose.yml**: 4 services — WordPress (6.9.1-php8.3-apache), MariaDB 11, WP-CLI, Adminer
- WordPress at http://localhost:8000, Adminer at http://localhost:8080
- DB creds: user `wordpress`, password `wordpress` (local only)

### Production (Fly.io)
- Single container: WordPress + MariaDB managed by supervisord
- Region: `cdg` (Paris), VM: shared-cpu-1x, 512MB RAM
- Fly volume `wp_data` mounted at `/data` (symlinked to MySQL data dir and wp-content/uploads)
- App URL: https://plum-village-portfolio.fly.dev/

### Production Entrypoint (`scripts/entrypoint.sh`)
Boot sequence:
1. Create data dirs on Fly volume (`/data/mysql`, `/data/uploads`)
2. Symlink uploads into wp-content
3. Initialize MariaDB data dir if first boot
4. Replace `/var/lib/mysql` with symlink to volume (must `rm -rf` first — Debian package creates a real directory)
5. Create `/run/mysqld` socket directory
6. Start MariaDB temporarily, create DB/user, stop it
7. Run WordPress `docker-entrypoint.sh` to populate `/var/www/html`
8. Start supervisord (Apache + MariaDB)

## Gotchas Learned During Production Setup

- **MariaDB binary path**: Debian installs `mariadbd` at `/usr/sbin/mariadbd`, not `/usr/bin/`
- **MySQL socket directory**: `/run/mysqld/` doesn't exist in the container by default — must create it before starting MariaDB
- **`ln -sfn` vs real directories**: Can't symlink over a non-empty directory; must `rm -rf /var/lib/mysql` first
- **PHP MySQL socket**: When `WORDPRESS_DB_HOST=localhost`, PHP uses Unix socket (which has no default path configured). Use `127.0.0.1` to force TCP connection instead.
- **WordPress files in production**: Our custom `ENTRYPOINT` replaces the upstream one, so WordPress files don't get copied to `/var/www/html` automatically. Must explicitly call `docker-entrypoint.sh` in our entrypoint.
- **`.env` sourcing**: Can't `source .env` in bash scripts — the Fly API key contains spaces and special chars that break parsing. Use `grep` + `cut` to extract individual variables instead.

## Secrets Management

- `.env` is gitignored — contains Fly.io API key, LearnDash license, and production WP admin password
- `.env.example` is committed as a template
- Production DB password set via `fly secrets set WORDPRESS_DB_PASSWORD=...`
- No production passwords are committed to the repo

## Project Phases

- **Phase 1** (current): Vanilla WordPress workflow — local dev, deploy pipeline, content sync
- **Phase 2** (planned): Custom theme, LearnDash (`sfwd-lms.5.0.2.zip` already in project root), BuddyPress
