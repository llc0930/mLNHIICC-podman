#!/bin/sh
image_ver="$(cat ./settings/image_ver)"

podman rm -f nhiicc myregistry
podman rmi -f docker.io/library/alpine:edge \
  docker.io/library/registry:2 \
  localhost:5000/nhiicc:"$image_ver" \
  localhost:5000/nhiicc:latest
