.PHONY: all help build console db_create db_seed db_destroy db_reset down destroy guard pessimize shell test up e2e
all: help

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

ifndef SERVICE
SERVICE=web
endif

ifdef PROD
DC=docker compose -f docker-compose.localprod.yml
SHELL_CMD=sh
else
DC=docker compose
SHELL_CMD=zsh
endif

DC_RUN=$(DC) run $(DC_ENV) --rm $(SERVICE)
RSPEC_SEED:=$(od -vAn -N2 -tu2 < /dev/urandom | tr -d " \t\n\r")

build: Dockerfile ## build the container image
	$(DC) build

pull: ## pull the container images
	$(DC) pull

pull_dependencies: ## pull the container images of app dependencies
	$(DC) pull database redis mailer chrome

console: ## open a rails console inside the container
	$(DC_RUN) bundle exec rails console

db_create: ## database drop, create, load the schema on the given env
	$(DC_RUN) bundle exec rake db:drop db:create db:schema:load RAILS_ENV=${RAILS_ENV}

db_migrate: ## run pending migrations
	$(DC_RUN) bundle exec rake db:migrate:with_data RAILS_ENV=${RAILS_ENV}

db_rollback: ## run pending migrations
	$(DC_RUN) bundle exec rake db:rollback:with_data RAILS_ENV=${RAILS_ENV} STEP=1

db_seed: ## seed the database
	$(DC_RUN) bundle exec rake db:seed RAILS_ENV=${RAILS_ENV}

db_destroy: down ## database drop
	$(DC_RUN) bundle exec rake db:drop

db_reset: down ## db_create for RAILS_ENV=development and RAILS_ENV=test
	$(MAKE) db_create RAILS_ENV=development
	$(MAKE) db_create RAILS_ENV=test

down: ## containers stop all
	$(DC) down --remove-orphans

destroy: ## containers stop all and destroy volumes
	$(DC) down --remove-orphans -v

ci_rubocop: ## Run rubocop (On CI)
	$(DC_RUN) bundle exec rubocop --format github

ci_zeitwerk: ## Run zeitwerk eager clas loading (On CI)
	$(DC_RUN) bundle exec rake zeitwerk:check

ci_setup_test: ## Prepare a local TEST environment (On CI)
	$(MAKE) pull_dependencies
	$(DC_RUN) bundle exec rake parallel:create RAILS_ENV=test
	$(DC_RUN) bundle exec rake parallel:load_schema RAILS_ENV=test

ci_test_unit: ## Rspec / Unit tests (On CI)
	$(eval RSPEC_SEED=$(shell od -vAn -N2 -tu2 < /dev/urandom | tr -d " \t\n\r"))
	$(eval DC_ENV=--env RAILS_ENV=test --env RSPEC_SEED=${RSPEC_SEED})
	$(DC_RUN) bundle exec parallel_rspec --exclude-pattern='spec/(features|system)' -- --format RSpec::Github::Formatter --

ci_test_feature: chrome ## Feature tests (On CI)
	$(DC_RUN) bundle exec rspec --format RSpec::Github::Formatter --pattern 'features/**/*_spec.rb'

ci_test_system: chrome ## System tests (On CI)
	$(DC_RUN) bundle exec rspec --format RSpec::Github::Formatter --pattern 'system/**/*_spec.rb'

ci_setup_e2e: ## Setup end-to-end test environmnet (On CI)
	$(MAKE) pull_dependencies
	$(MAKE) setup_test
	$(MAKE) setup_localprod
	$(MAKE) up_and_wait PROD=1

ci_e2e: chrome
	$(eval DC_ENV=--env CAPYBARA_APP_HOST=web:3000)
	$(DC_RUN) bundle exec rspec --format RSpec::Github::Formatter --pattern 'system/**/*_spec.rb'

guard: chrome ## Run guard for TDD/BDD
	$(eval DC_ENV=--env CAPYBARA_SERVER_SILENT=1)
	$(DC_RUN) bundle exec guard

guard_system: chrome ## Run guard for TDD/BDD of system tests
	$(eval DC_ENV=--CAPYBARA_APP_HOST=web)
	$(DC_RUN) bundle exec guard

pessimize: ## Run pessimize gem
	$(DC_RUN) pessimize -c patch --no-backup
	$(DC_RUN) bundle install

shell: ## Open a shell (zsh) inside the container
	$(DC_RUN) $(SHELL_CMD)

chrome: ## Start the chrome for tests (access it at http://localhost:3333)
	$(DC) up -d chrome

setup_dev: down ## Run all commands to prepare a local DEVELOPMENT environment
	$(MAKE) db_create RAILS_ENV=development
	$(MAKE) db_migrate RAILS_ENV=development
	$(MAKE) db_seed RAILS_ENV=development

setup_test: ## Run all commands to prepare a local TEST environment
	$(MAKE) db_create RAILS_ENV=test

setup_localprod:
	$(MAKE) db_create PROD=1 RAILS_ENV=production
	$(MAKE) db_seed PROD=1 RAILS_ENV=production

test: test_unit

test_unit: chrome ## run unit tests
	$(DC_RUN) bundle exec rspec --format=documentation --exclude-pattern 'spec/features/**/*_spec.rb, spec/system/**/*_spec.rb'

test_feature: chrome ## run feature tests
	$(DC_RUN) bundle exec rspec --format=documentation --pattern 'spec/features/**/*_spec.rb'

test_system: chrome ## run end-to-end tests
	$(DC_RUN) bundle exec rspec --format=documentation --pattern 'spec/system/**/*_spec.rb'

test_e2e: chrome ## run end-to-end tests on a pristine environment build as production
	$(eval DC_ENV=--env CAPYBARA_APP_HOST=web:3000)
	$(DC_RUN) bundle exec rspec --format=documentation --pattern 'spec/system/**/*_spec.rb'

up: ## start all services
	$(DC) up -d

up_localprod:
	$(MAKE) build PROD=1
	$(MAKE) destroy PROD=1
	$(MAKE) setup_localprod
	$(MAKE) up_and_wait PROD=1

up_and_wait: ## start all services and wait for them to be ready
	$(DC) up -d --wait --wait-timeout 300
