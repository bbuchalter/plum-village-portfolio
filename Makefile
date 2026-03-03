.PHONY: up down logs wp setup export import-prod deploy

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

export:
	bash scripts/export-content.sh

import-prod:
	bash scripts/import-content.sh

deploy:
	fly deploy

# Catch-all to allow `make wp plugin list` style commands
%:
	@:
