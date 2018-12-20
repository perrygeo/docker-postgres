
SHELL = /bin/bash
TAG = latest

# relative to pwd
TESTDIR = _pgdata_test

all: start-db

build:
	docker build --tag perrygeo/postgres:$(TAG) --file Dockerfile .

shell: build
	docker run \
		--volume $(shell pwd)/:/app \
		--rm -it --tty \
		perrygeo/postgres:$(TAG) \
		/bin/bash

test:
	rm -rf $(TESTDIR) || echo "skip"
	mkdir $(TESTDIR)
	chmod 777 $(TESTDIR)
	docker run --rm \
		--name postgres-test-server \
		--volume `pwd`/$(TESTDIR):/var/lib/pgsql/data \
		-e POSTGRES_PASSWORD=password \
		-e POSTGRES_USER=postgres \
		-e PGDATA=/var/lib/pgsql/data/pgdata11 \
		-e POSTGRES_DB=db \
		-p 9432:5432 \
		perrygeo/postgres:$(TAG) \
		postgres --version
	rm -rf $(TESTDIR)

start-db: build
	docker kill postgres-server || echo "no container to kill"
	mkdir pgdata || echo "pgdata already exists"
	# TODO -e POSTGRES_INITDB_ARGS="--data-checksums --locale=en_US.UTF-8 --encoding=UTF8"
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
	    perrygeo/postgres:$(TAG) \
		postgres -c 'config_file=/etc/postgresql/postgresql.conf'
