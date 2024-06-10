.PHONY: all help build console db_create db_seed db_destroy down destroy guard pessimize shell setup_dev setup_test test up ups e2e
all: help

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

ifndef SERVICE
SERVICE:=web
endif

ifdef PROD
DC:=docker compose -f docker-compose.localprod.yml
else
DC:=docker compose
endif

DC_RUN:=$(DC) run --rm $(SERVICE)

build: Dockerfile ## build the container image
	$(DC) build

console: ## open a rails console inside the container
	$(DC_RUN) bundle exec rails console

db_create: down ## database drop, create, load the schema on the given env
	$(DC_RUN) bundle exec rake db:drop db:create db:schema:load RAILS_ENV=${RAILS_ENV}

db_migrate: ## run pending migrations
	$(DC_RUN) bundle exec rake db:migrate RAILS_ENV=${RAILS_ENV}

db_migration_test: ## run pending migrations
	$(MAKE) db_create RAILS_ENV=development
	$(MAKE) db_migrate RAILS_ENV=development
	$(MAKE) db_create RAILS_ENV=test
	$(MAKE) db_migrate RAILS_ENV=test

db_seed: ## seed the database
	$(DC_RUN) bundle exec rake db:seed RAILS_ENV=${RAILS_ENV}

db_destroy: down ## database drop
	$(DC_RUN) bundle exec rake db:drop RAILS_ENV=development

down: ## containers stop all
	$(DC) down --remove-orphans

destroy: ## containers stop all and destroy volumes
	$(DC) down --remove-orphans -v

gh_rubocop:
	$(DC_RUN) bundle exec rubocop --format github

gh_zeitwerk: db_create
	$(DC_RUN) bundle exec rake zeitwerk:check

gh_rspec: setup_test
	$(DC_RUN) bundle exec rspec --format RSpec::Github::Formatter

guard: chrome ## run guard for TDD/BDD
	$(DC_RUN) bundle exec guard

chrome: ## Start the chrome for tests (access it at http://localhost:3333)
	$(DC) up -d chrome

pessimize: ## run pessimize gem
	$(DC_RUN) pessimize -c patch --no-backup && bundle install

routes: ## run pessimize gem
	$(DC_RUN) bundle exec rails routes

shell: ## open a shell (zsh) inside the container
	$(DC_RUN) zsh

setup_dev: down ## Run all commands to prepare a local DEVELOPMENT environment
	$(MAKE) db_create RAILS_ENV=development
	$(MAKE) db_migrate RAILS_ENV=development
	$(MAKE) db_seed RAILS_ENV=development

setup_test: down ## Run all commands to prepare a local TEST environment
	$(MAKE) db_create RAILS_ENV=test

setup_localprod: down
	$(MAKE) db_create PROD=1

test: ## run rspec
	$(DC_RUN) bundle exec rspec

up: ## start all services
	$(DC) up -d
