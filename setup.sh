#!/bin/bash
if ! [ -x "$(command -v docker)" ]; then
  echo "Docker ist nicht installiert."
  exit 1
fi
IMAGE_NAME="mkdocs-env"
if ! docker image inspect $IMAGE_NAME > /dev/null 2>&1; then
  docker build -t $IMAGE_NAME .
fi
docker run --rm -it -p 8000:8000 -v $(pwd):/app $IMAGE_NAME
