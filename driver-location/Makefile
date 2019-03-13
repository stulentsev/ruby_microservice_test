.PHONY: all test deps down test_dev_cmd test_dev

all:
	@docker-compose -f docker-compose.local.yaml build

test:
	@docker-compose -f docker-compose.local.yaml run runner bundle exec rspec

deps:
	@docker-compose -f docker-compose.local.yaml up -d redis nsqlookupd nsqd

down:
	@docker-compose -f docker-compose.local.yaml down

dev_web:
	@docker-compose -f docker-compose.local.yaml up dev

dev_consumer:
	@docker-compose -f docker-compose.local.yaml run dev bundle exec bin/consumer start --workers=1

dev_test:
	@docker-compose -f docker-compose.local.yaml run dev bundle exec rspec
