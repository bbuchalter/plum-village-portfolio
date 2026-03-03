.PHONY: up down logs wp setup seed export import-prod deploy theme-activate plugin-activate learndash-install block-dev block-build

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f wordpress

wp:
	docker compose run --rm wpcli wp $(filter-out $@,$(MAKECMDGOALS))

setup:
	bash scripts/setup.sh

seed:
	docker compose run --rm wpcli bash /var/www/html/scripts/seed-content.sh

export:
	bash scripts/export-content.sh

import-prod:
	bash scripts/import-content.sh

deploy:
	railway up --no-gitignore

theme-activate:
	docker compose run --rm wpcli wp theme activate plum-village

plugin-activate:
	docker compose run --rm wpcli wp plugin activate plum-village-blocks

learndash-install:
	docker compose cp sfwd-lms.5.0.2.zip wordpress:/var/www/html/sfwd-lms.zip
	docker compose run --rm wpcli wp plugin install /var/www/html/sfwd-lms.zip --activate

block-dev:
	cd plugins/plum-village-blocks && npm start

block-build:
	cd plugins/plum-village-blocks && npm run build

# Catch-all to allow `make wp plugin list` style commands
%:
	@:
