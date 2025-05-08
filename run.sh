#!/bin/sh
port="$(cat ./settings/port)"

podman run --replace --name myregistry \
  -d -p "$port":"$port" \
  docker.io/library/registry:2
#-v /opt/registry:/var/lib/registry

podman run --replace --name nhiicc \
  --net host --tls-verify=false \
  -v /run/pcscd:/var/run/pcscd \
  localhost:"$port"/nhiicc
