
SHELL = /bin/bash
TAG ?= latest
REPO ?= perrygeo/postgres

all: build test

build:
	docker build --tag $(REPO):$(TAG) --file Dockerfile .
	docker tag $(REPO):$(TAG) $(REPO):latest

shell:
	docker run \
		--volume $(shell pwd)/:/app \
		--rm -it --tty \
		$(REPO):$(TAG) \
		/bin/bash

test:
	docker run --rm \
		--name postgres-test-server \
		-e PGDATA=/tmp/pgdata \
		$(REPO):$(TAG) \
		postgres --version
