# CLAUDE.md

## Project Overview

WordPress learning portfolio for Plum Village. Local dev via Docker Compose, production on Railway with managed MySQL.

**Production**: https://plum-village-portfolio.buchalter.dev

## Key Commands

- `make up` / `make down` — start/stop local dev
- `make setup` — first-time WordPress install (admin/admin)
- `make wp <command>` — run WP-CLI (e.g., `make wp plugin list`)
- `make deploy` — deploy to Railway (`railway up --no-gitignore`)
- `make export` — dump local DB to `data/seed.sql`
- `make import-prod` — push local DB to production (requires `.env` with `MYSQL_PUBLIC_URL` and `WP_ADMIN_PASSWORD`)
- `make block-dev` / `make block-build` — custom block plugin development

## Architecture

### Local Development
- **docker-compose.yml**: 4 services — WordPress (6.9.1-php8.3-apache), MariaDB 11, WP-CLI, Adminer
- WordPress at http://localhost:8000, Adminer at http://localhost:8080
- Theme and block plugin are bind-mounted for live editing
- DB creds: user `wordpress`, password `wordpress` (local only)

### Production (Railway)
- **WordPress service**: Apache as the single process (no supervisord, no bundled DB)
- **MySQL service**: Railway managed MySQL — separate service, automatic backups
- **Volume**: mounted at `/data`, stores `uploads/` only (symlinked to `wp-content/uploads`)
- **DB connection**: `WORDPRESS_DB_*` env vars use Railway reference variables (e.g., `${{MySQL.MYSQLHOST}}`)
- **PORT**: must be set to `80` — Railway won't route traffic without it

### Dockerfile
- WordPress core baked in at build time (`cp -a /usr/src/wordpress/. /var/www/html/`)
- Custom theme + plugins (plum-village-blocks, LearnDash, BuddyPress) installed at build time
- WP-CLI installed for remote admin via `railway ssh`
- No MariaDB, no supervisord — Apache is the single process
- Deployed with `--no-gitignore` because `sfwd-lms.*.zip` is gitignored but needed in the build

### Entrypoint (`scripts/entrypoint.sh`)
1. Create uploads dir on volume (`/data/uploads`), symlink to wp-content
2. Remove conflicting Apache MPM modules (Railway re-enables `mpm_event` at runtime)
3. Delegate to `docker-entrypoint.sh` (generates wp-config.php, exec's Apache)

### Content Pipeline
- One-direction: local → production (full database replacement)
- `make export` dumps local DB, `make import-prod` pushes it
- Import connects directly to Railway's public MySQL endpoint (bypasses `railway ssh` quoting issues)
- After import: rewrites URLs (`localhost:8000` → production) and resets admin password

## Gotchas

- **Custom ENTRYPOINT replaces upstream**: Must bake WP core at build time and call `docker-entrypoint.sh` from our entrypoint (it generates wp-config.php from env vars)
- **Railway re-enables Apache MPM modules at runtime**: `a2dismod` at build time doesn't stick — must `rm -f` the symlinks in the entrypoint
- **`railway ssh` splits arguments with spaces**: Use direct MySQL connection for DB operations, or `wp option update` for single-word values only
- **`railway up` only uploads git-tracked files**: Use `--no-gitignore` flag; `.dockerignore` controls the build context instead
- **Don't `source .env`**: Values with spaces/special chars break. Use `grep` + `cut` to extract individual variables

## Secrets

- `.env` (gitignored) — `MYSQL_PUBLIC_URL`, `WP_ADMIN_PASSWORD`, `LEARNDASH_LICENSE_KEY`
- `.env.example` — committed template
- Production DB creds — managed by Railway (injected via reference variables)
- No secrets in the repo

## Project Structure

```
config/php.ini                     # PHP overrides (upload limits, memory)
plugins/plum-village-blocks/       # Custom Gutenberg block plugin (src/ → build/)
themes/plum-village/               # Custom block theme (theme.json, templates, patterns)
scripts/setup.sh                   # Local WP install
scripts/entrypoint.sh              # Production boot sequence
scripts/export-content.sh          # Local DB → data/seed.sql
scripts/import-content.sh          # DB → Railway + URL rewrite + credential reset
docker-compose.yml                 # Local dev (4 services)
Dockerfile                         # Production image
Makefile                           # All commands
```
