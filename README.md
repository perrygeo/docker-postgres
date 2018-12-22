# Docker images for Postgres

[![Build Status](https://travis-ci.com/perrygeo/docker-postgres.svg?branch=master)](https://travis-ci.com/perrygeo/docker-postgres)

Check out [`perrygeo/postgres` on Dockerhub](https://hub.docker.com/r/perrygeo/postgres)

This is my take on a Dockerized PostgreSQL 11.1 database with some useful extensions
including [PostGIS](https://www.postgis.net/) and [TimescaleDB](https://www.timescale.com/).
The primary goal is to quickly launch a local postgres
server for development, one with reasonablly current versions and built from source.

Futures goals include launching this as a production grade
Postgres deployment on AWS and Digitial Ocean. Looking at
projects like [Patroni](https://github.com/zalando/patroni) for inspiration.

The family tree
```
debian:stretch-slim
      |
      v
python:3.6-slim-stretch
      |
      v
perrygeo/gdal-base:latest
      |
      V
perrygeo/postgres:latest
```
See [`perrygeo/gdal-base`](https://hub.docker.com/r/perrygeo/gdal-base) for details on the C shared libraries available,
notably GDAL, proj and GEOS for use in PostGIS. The following package versions are built from source:

```
POSTGIS 2.5.1
POSTGRES 11.1
PROTOBUF 3.6.1
PROTOBUF_C 1.3.1
TIMESCALE 1.1.1
```

Uses the `docker_entrypoint.sh` script from the offical postgres image
thus most of the best practices described in [the documentation](https://hub.docker.com/_/postgres/)
also apply to this project.

## Using the image locally

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

## Using it in production

Not yet.

## License

Docker image licensing [is a mess](https://opensource.stackexchange.com/a/7015) and in lieu of clear best practices, I'm making the source code and the associated images on dockerhub available as **public domain**.

I provide no warranty of any kind.
You're on your own if you choose to use any of these resources.
If the images work for you, great!
Please `docker pull` it, fork it, `git clone` it, download it, whatever.
Thanks to github, travis-ci and dockerhub
for donating the computing resources to support open source projects such as this.


## Contributing

Ideas for additional drivers or software? Bug fixes? Please create a pull request on this repo with:

* a description.
* code + an automated test for the new functionality.
* results of trying it in production.

If your proposal is aligned with the project's goals, I'll gladly accept it!
