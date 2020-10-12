# PostgreSQL database server

set -e

# Change the default port to avoid collisions
# with other postgres instances
HOST_PORT=6432

NAME=postgres-server
DOCKER_REPO=perrygeo/postgres
TAG=latest

# Assumes make or make pull has already been run
mkdir pgdata || :
mkdir mnt_data || :
mkdir logs || :
docker run --rm --name $NAME \
  --volume `pwd`/pgdata:/var/lib/pgsql/data \
  --volume `pwd`/mnt_data:/mnt/data \
  --volume `pwd`/logs:/var/log/postgres \
  --volume `pwd`/pg_hba.conf:/etc/postgresql/pg_hba.conf \
  --volume `pwd`/postgresql.conf:/etc/postgresql/postgresql.conf \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_USER=postgres \
  -e PGDATA=/var/lib/pgsql/data/pgdata13 \
  -e POSTGRES_INITDB_ARGS="--data-checksums --encoding=UTF8" \
  -e POSTGRES_DB=db \
  -p ${HOST_PORT}:5432 \
  ${DOCKER_REPO}:${TAG} \
  postgres \
    -c 'config_file=/etc/postgresql/postgresql.conf' \
    -c 'hba_file=/etc/postgresql/pg_hba.conf'
