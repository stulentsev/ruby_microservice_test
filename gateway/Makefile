.PHONY: all test

all:
	@docker-compose -f docker-compose.local.yaml build

test:
	@docker-compose -f docker-compose.local.yaml run runner rspec

down:
	@docker-compose -f docker-compose.local.yaml down

dev_test:
	@docker-compose -f docker-compose.local.yaml run dev rspec
