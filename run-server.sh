# PostgreSQL database server

set -e

NAME=postgres-server
DOCKER_REPO=perrygeo/postgres
TAG=latest

case $1 in

prep)
    docker pull ${DOCKER_REPO}:${TAG}
    mkdir pgdata || :
    mkdir mnt_data || :
    ;;

start)
    $0 stop || :
    $0 prep
    docker run --rm -d --name $NAME \
      --volume `pwd`/pgdata:/var/lib/pgsql/data \
      --volume `pwd`/mnt_data:/mnt/data \
      --volume `pwd`/pg_hba.conf:/etc/postgresql/pg_hba.conf \
      -e POSTGRES_PASSWORD=jXX9nLZUy2mB \
      -e POSTGRES_USER=postgres \
      -e PGDATA=/var/lib/pgsql/data/pgdata11 \
      -e POSTGRES_INITDB_ARGS="--data-checksums --encoding=UTF8" \
      -e POSTGRES_DB=db \
      -p 5432:5432 \
      ${DOCKER_REPO}:${TAG} \
      postgres \
        -c 'config_file=/etc/postgresql/postgresql.conf' \
        -c 'hba_file=/etc/postgresql/pg_hba.conf'
    ;;

stop)
    docker stop $NAME
    ;;

reload)
    docker kill --signal=SIGHUP $NAME
    ;;

status)
    docker ps | grep $NAME
    ;;

*)
    echo "specify prep|start|stop|reload|status"
    exit 1
    ;;
esac
