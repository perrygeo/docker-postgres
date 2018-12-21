
SHELL = /bin/bash
TAG = latest
REPO ?= perrygeo/postgres

all: start-db

build:
	docker build --tag $(REPO):$(TAG) --file Dockerfile .

shell: build
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

start-db: build
	docker kill postgres-server || echo "no container to kill"
	mkdir pgdata || echo "pgdata already exists"
	# Consider adding initdb args
	# -e POSTGRES_INITDB_ARGS="--data-checksums --locale=en_US.UTF-8 --encoding=UTF8"
	docker run --rm \
	   	-d \
		--name postgres-server \
		--volume `pwd`/pgdata:/var/lib/pgsql/data \
		--volume ${PWD}/mnt_data:/mnt/data \
		-e POSTGRES_PASSWORD=password \
		-e POSTGRES_USER=postgres \
		-e PGDATA=/var/lib/pgsql/data/pgdata11 \
		-e POSTGRES_DB=db \
		-p 5432:5432 \
		$(REPO):$(TAG) \
		postgres -c 'config_file=/etc/postgresql/postgresql.conf'
