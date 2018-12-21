#!/bin/bash
set -e

# DOCKER_PASS must be added as a secure environment variable
# Dockerhub repository name set in .travis.yml as $REPO
DOCKER_USER=perrygeo

echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
docker push $REPO
