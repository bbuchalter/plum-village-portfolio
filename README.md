# Plum Village Portfolio

A WordPress-based learning portfolio for Plum Village, deployed on [Railway](https://railway.app).

**Production URL**: https://plum-village-portfolio.buchalter.dev

This project demonstrates a complete local-to-production workflow for WordPress using Docker, WP-CLI, and infrastructure-as-code. All setup, deployment, and content management happens from the command line — no clicking through dashboards.

## Why WordPress?

The portfolio needs a CMS that supports online learning (LearnDash), community features (BuddyPress), and content management by non-developers. WordPress has the plugin ecosystem, and the people maintaining the content already know it.

The engineering challenge is making WordPress *development* modern — version-controlled, reproducible, and deployable from the terminal.

## What's Demonstrated

This portfolio demonstrates the technical skills required for the Plum Village Senior Web Developer role:

- **Custom theme development** — Block theme with FSE templates, `theme.json` design system, LearnDash template overrides
- **Custom plugin development** — 3 Gutenberg blocks: Dharma Talk (static), Practice Pause (interactive JS), Course Grid (dynamic ServerSideRender)
- **PHP** — LearnDash template overrides (`learndash_get_course_steps()`, `learndash_is_lesson_complete()`), server-side block rendering, WordPress hooks/filters
- **JavaScript** — Vanilla JS breathing exercise, React block editors with InspectorControls, `@wordpress/server-side-render`
- **SASS** — Per-block `style.scss` (frontend) and `editor.scss` (editor) compiled via `@wordpress/scripts`
- **LearnDash** — Demo course with custom templates, lesson progress tracking, dynamic Course Grid block
- **Git & DevOps** — Docker Compose local dev, Railway production with managed MySQL, WP-CLI content pipeline

## Architecture

```
┌──────────────────────────────────────────────────────┐
│                Local Development                      │
│                                                       │
│  docker compose up                                    │
│  ┌───────────┐  ┌──────────┐  ┌───────┐  ┌────────┐ │
│  │ WordPress  │  │ MariaDB  │  │WP-CLI │  │Adminer │ │
│  │ :8000      │→ │ :3306    │  │(tasks)│  │ :8080  │ │
│  └───────────┘  └──────────┘  └───────┘  └────────┘ │
└──────────────────────────────────────────────────────┘
       │
       │  make export → data/seed.sql → make import-prod
       ▼
┌──────────────────────────────────────────────────────┐
│             Production (Railway)                      │
│                                                       │
│  ┌───────────┐       ┌─────────────────────┐         │
│  │ WordPress  │  →    │ MySQL (managed)     │         │
│  │  Apache    │       │ Railway service     │         │
│  │  :80       │       │ automatic backups   │         │
│  └───────────┘       └─────────────────────┘         │
│       │                                               │
│  Railway Volume (/data)                               │
│  └── uploads/       (symlinked to wp-content)         │
└──────────────────────────────────────────────────────┘
```

### Design decisions

**Two-service production architecture.** WordPress and MySQL run as separate Railway services. An earlier Fly.io setup bundled MariaDB inside the WordPress container with supervisord — it kept OOM-crashing on 512MB VMs. Extracting the database into a managed service eliminated that class of problems. The WordPress container now runs Apache as its single process.

**WordPress core baked into the image.** The Dockerfile copies WordPress core files at build time (`cp -a /usr/src/wordpress/. /var/www/html/`). This is necessary because our custom `ENTRYPOINT` replaces the upstream WordPress image's entrypoint, which normally populates `/var/www/html` on first boot. We call `docker-entrypoint.sh` from our entrypoint to preserve the wp-config.php generation behavior.

**Full database replacement for content sync.** WordPress stores absolute URLs, serialized PHP objects, and auto-incremented IDs across interconnected tables. There's no clean way to merge two WordPress databases. Instead, content is authored locally and the entire production database is replaced on import. This works because the site is a portfolio — there's no user-generated content to preserve.

**Direct MySQL connection for imports.** The `railway ssh` command has argument quoting issues (spaces get split, flags get swallowed inside `bash -c` wrappers). The import script bypasses SSH entirely by connecting to Railway's public MySQL endpoint directly through the local MariaDB Docker container.

## Local Development

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Railway CLI](https://docs.railway.app/guides/cli) (for deployment and production management)

### Getting started

```bash
# Start all services
make up

# First time only: install WordPress and configure permalinks
make setup

# Install LearnDash plugin
make learndash-install

# Seed demo content (1 course, 4 lessons, portfolio page)
make seed

# View logs
make logs

# Stop services
make down
```

After `make setup`:

| Service | URL | Credentials |
|---------|-----|-------------|
| WordPress | http://localhost:8000 | admin / admin |
| Adminer (DB UI) | http://localhost:8080 | server: `db`, user: `wordpress`, password: `wordpress` |

### How local dev works

Docker Compose runs four services:

1. **WordPress** (`wordpress:6.9.1-php8.3-apache`) — web server, files persisted to a named volume
2. **MariaDB** (`mariadb:11`) — database, also on a named volume
3. **WP-CLI** (`wordpress:cli`) — disposable container for scripted admin tasks, shares WordPress's volume
4. **Adminer** — lightweight database GUI

The WP-CLI container is the key to the headless workflow. `make setup` runs the WordPress installer via WP-CLI, making the environment reproducible from a single command.

The custom theme and block plugin are bind-mounted into the WordPress container, so changes appear immediately without rebuilding.

### WP-CLI

Any WP-CLI command works through Make:

```bash
make wp plugin list
make wp theme list
make wp user list
make wp post list
```

### Custom block development

The `plum-village-blocks` plugin uses WordPress's `@wordpress/scripts` toolchain:

```bash
make block-dev    # Start webpack dev server with hot reload
make block-build  # Production build
```

Three blocks:

| Block | Type | Description |
|-------|------|-------------|
| **Dharma Talk** | Static | Card with teacher, duration, description — data entered in editor via RichText |
| **Practice Pause** | Interactive | Mindfulness bell with timed breathing exercise — vanilla JS state machine |
| **Course Grid** | Dynamic | Queries LearnDash courses at render time — React editor with ServerSideRender + PHP render callback |

### LearnDash integration

LearnDash content is seeded via WP-CLI (`make seed`), which creates:

- 1 course ("Foundations of Mindfulness") with 4 lessons
- A "Technical Skills Portfolio" page documenting what the site demonstrates

The theme overrides LearnDash's content templates (`themes/plum-village/learndash/`) for custom course and lesson rendering, plus block theme templates (`templates/single-sfwd-*.html`) for page structure.

## Content Pipeline

Content flows one direction: **local → production**.

### Export local database

```bash
make export
```

Dumps the local database to `data/seed.sql` using WP-CLI's `db export`.

### Import to production

```bash
make import-prod
```

This script (`scripts/import-content.sh`) does three things:

1. **Imports** `data/seed.sql` into Railway's MySQL via a direct connection (using the local MariaDB container as the client, connecting to Railway's public MySQL endpoint)
2. **Rewrites URLs** — `wp search-replace` replaces every `http://localhost:8000` with the production URL across all tables, including inside serialized PHP data
3. **Resets admin credentials** — since the import overwrites the production database with local data, the admin user reverts to local credentials. The script restores the production password from `.env`

### Required environment variables

The import script reads from `.env` (see `.env.example`):

- `MYSQL_PUBLIC_URL` — Railway's public MySQL connection string (find it in Railway dashboard under the MySQL service)
- `WP_ADMIN_PASSWORD` — production admin password

## Production Deployment

### First-time Railway setup

```bash
# Create a Railway project
railway init

# Add managed MySQL
railway add --database mysql

# Create a WordPress service and set env vars (via Railway dashboard):
#   WORDPRESS_DB_HOST    = ${{MySQL.MYSQLHOST}}
#   WORDPRESS_DB_USER    = ${{MySQL.MYSQLUSER}}
#   WORDPRESS_DB_PASSWORD = ${{MySQL.MYSQLPASSWORD}}
#   WORDPRESS_DB_NAME    = ${{MySQL.MYSQLDATABASE}}
#   PORT                 = 80

# Create a volume on the WordPress service, mounted at /data

# Add a custom domain (or use the generated railway.app subdomain)
railway domain

# Link CLI to the wordpress service
railway service wordpress

# Build and deploy
make deploy

# Push local content to production
make export && make import-prod
```

### Subsequent deploys

```bash
make deploy
```

This runs `railway up --no-gitignore`, which uploads all project files (including the gitignored LearnDash zip) and builds the Docker image on Railway.

### The production container

The Dockerfile builds a single-process container:

- Starts from `wordpress:6.9.1-php8.3-apache`
- Installs WP-CLI for remote admin tasks via `railway ssh`
- Bakes in WordPress core files, the custom theme, and all plugins (plum-village-blocks, LearnDash, BuddyPress)
- Runs Apache as the only process — no supervisor, no bundled database

The entrypoint (`scripts/entrypoint.sh`) handles three things at boot:

1. Creates the uploads directory on the persistent volume (`/data/uploads`)
2. Symlinks it into `wp-content/uploads`
3. Disables conflicting Apache MPM modules (Railway's runtime re-enables `mpm_event` alongside `mpm_prefork`)
4. Delegates to WordPress's `docker-entrypoint.sh`, which generates `wp-config.php` from `WORDPRESS_DB_*` env vars and exec's Apache

### Secrets management

- **`.env`** (gitignored) — contains `MYSQL_PUBLIC_URL`, `WP_ADMIN_PASSWORD`, and `LEARNDASH_LICENSE_KEY`
- **`.env.example`** — committed template showing required variables without values
- **Production DB credentials** — managed by Railway, injected as env vars via reference variables (`${{MySQL.MYSQLHOST}}`, etc.)
- **No secrets in the repo** — all sensitive values live in `.env` locally or in Railway's environment variable UI

### File upload to Railway

Railway normally only uploads git-tracked files. The LearnDash plugin zip (`sfwd-lms.5.0.2.zip`) is gitignored (it's a 20MB binary), so `make deploy` uses `railway up --no-gitignore` to include it. The `.dockerignore` file controls what enters the Docker build context instead.

## Lessons Learned

**WordPress stores absolute URLs everywhere.** Every link, image, and site reference is a full URL in the database (`http://localhost:8000/wp-content/uploads/photo.jpg`). Moving between environments requires `wp search-replace` across all tables. It handles serialized PHP data too — a naive find-and-replace would corrupt serialized string lengths.

**Custom entrypoints replace, not extend, the base image's.** Defining `ENTRYPOINT` in a Dockerfile overwrites the parent image's entrypoint entirely. The WordPress image's entrypoint generates `wp-config.php` from environment variables — critical behavior that's lost if you don't call it from your own entrypoint.

**Keep the database out of the application container.** Bundling MariaDB with supervisord inside a 512MB VM caused persistent OOM crashes. A managed database service eliminates this class of problems entirely — simpler Dockerfile, faster boots, no process manager.

**Railway re-enables Apache MPM modules at runtime.** Even after `a2dismod mpm_event` at build time, Railway's runtime layer re-enables it, causing "More than one MPM loaded" crashes. The fix is to remove the conflicting module symlinks in the entrypoint at runtime, not at build time.

**`railway ssh` has argument quoting limitations.** Arguments with spaces get split into separate words, and `bash -c` wrappers swallow certain flags like `--allow-root`. For simple commands (no spaces) it works fine. For complex operations, connect directly to Railway's public MySQL endpoint or use the wp-admin dashboard.

**Railway requires a `PORT` environment variable.** Even though the Dockerfile `EXPOSE`s port 80, Railway doesn't route public traffic to the container without an explicit `PORT=80` env var.

**`railway up` uses git-tracked files by default.** Files matching `.gitignore` patterns aren't uploaded to Railway. The `--no-gitignore` flag overrides this, and `.dockerignore` then controls what enters the Docker build context.

**Don't `source .env` in bash scripts.** Values with spaces and special characters break shell parsing. Use `grep '^VAR_NAME=' .env | cut -d= -f2-` to extract individual variables safely.

**LearnDash template overrides are content templates, not page templates.** The `learndash_template` filter intercepts templates that render inside `the_content()`. Calling `get_header()` or `the_content()` inside a LearnDash template override causes infinite recursion. The templates receive extracted variables (`$course_id`, `$content`, `$lessons`) and should output HTML directly. Page structure comes from block theme templates (`templates/single-sfwd-courses.html`).

**LearnDash lesson URLs are nested under courses.** Lessons live at `/courses/{course}/lessons/{lesson}/`, not `/lessons/{lesson}/`. A direct lesson URL redirects (302) to the nested version. Always use `get_permalink()` for LearnDash URLs.

## Project Structure

```
├── config/
│   └── php.ini                    # PHP overrides (upload limits, memory)
├── plugins/
│   └── plum-village-blocks/       # Custom Gutenberg block plugin
│       ├── src/                   # Block source (JSX, SCSS)
│       │   ├── dharma-talk/       # Static block
│       │   ├── practice-pause/    # Interactive block (vanilla JS)
│       │   └── course-grid/       # Dynamic block (ServerSideRender)
│       └── build/                 # Compiled block assets
├── themes/
│   └── plum-village/              # Custom block theme
│       ├── theme.json             # Design system (8 colors, 2 fonts, 5 spacing sizes)
│       ├── functions.php          # Theme setup + LearnDash hooks
│       ├── learndash/             # LearnDash template overrides
│       │   ├── course.php         # Single course: lesson list, progress, CTA
│       │   ├── lesson.php         # Single lesson: breadcrumbs, prev/next nav
│       │   └── course_list_template.php  # Course archive grid
│       ├── templates/             # Block templates (incl. sfwd-courses, sfwd-lessons)
│       ├── parts/                 # Template parts (header, footer)
│       └── patterns/              # Block patterns
├── scripts/
│   ├── setup.sh                   # Local WP install via WP-CLI
│   ├── seed-content.sh            # Create demo courses, lessons, portfolio page
│   ├── entrypoint.sh              # Production container boot sequence
│   ├── export-content.sh          # Dump local DB → data/seed.sql
│   └── import-content.sh          # Push DB to Railway + URL rewrite
├── data/                          # (gitignored) Database dumps
│   └── seed.sql
├── docker-compose.yml             # Local dev: 4 services
├── Dockerfile                     # Production: WordPress + Apache
├── Makefile                       # All commands
├── .env.example                   # Environment variable template
├── .dockerignore                  # Controls Docker build context
├── .railwayignore                 # Controls Railway upload context
└── sfwd-lms.5.0.2.zip            # (gitignored) LearnDash plugin
```
