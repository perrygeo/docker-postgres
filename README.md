# Docker images for Postgres

PostgreSQL 11.1 database with some useful extensions.

Based on [`perrygeo/gdal-base`](https://hub.docker.com/r/perrygeo/gdal-base) ([`python:3.6-slim-stretch`](https://github.com/docker-library/python/blob/master/3.6/stretch/slim/Dockerfile), `debian:stretch-slim`).

Uses the `docker_entrypoint.sh` script from the postgres docker image, thus most of the documentation applies to this project.

The following versions built from source:

```
POSTGIS 2.5.1
POSTGRES 11.1
PROTOBUF 3.6.1
PROTOBUF_C 1.3.1
TIMESCALE 1.1.0
```

## Using the image directly

```
make
```

will pull the base image, build the `perrygeo/postgres` image,
then (re)start the database server in the background with your local `pgdata` directory mounted for `$PGDATA`.


### Connect with `psql`

```
$ psql -U postgres -h localhost -d db
```

### Check postgres logs

The logs live in `$PGDATA/pg_log`. Since pgdata is mounted to the container, you can see them on
your local file system:

```
$ tail -f pgdata/pgdata11/pg_log/postgresql-...csv
```

### Run commands and login to the running container

```
docker exec postgres-server {command to execute}
```

You can use `docker exec -it postgres-server /bin/bash` to get an interactive shell.

## Extending this image

Probably don't. I think you'd have better luck copying this `Dockerfile` and modifying it according to your needs.

## License

Docker image licensing [is a mess](https://opensource.stackexchange.com/a/7015) and in lieu of clear best practices, I'm making the source code and the associated images on dockerhub available as **public domain**.

I provide no warranty of any kind.
You're on your own if you choose to use any of these resources.
If the images work for you, great!
Please `docker pull` it, fork it, `git clone` it, download it, whatever.
Thanks to github, travis-ci and dockerhub
for donating the computing resources to support open source projects such as this.


## Contributing

Ideas for additional drivers or software? Bug fixes? Please let me know.
If you're into Github, create a pull request on this repo. Otherwise, send me an email at matt@perrygeo.com.

Either way, I'll ask for

* a description.
* code + an automated test for the new functionality.
* results of trying it in production.

If your proposal is aligned with the project's goals, I'll gladly accept it!
