#!/bin/sh
set -x
image_ver="$(cat ./settings/image_ver)"
port="$(cat ./settings/port)"

sudo apt-get install --no-install-recommends -y podman buildah
sudo apt-get install --no-install-recommends -y ca-certificates pcscd pcsc-tools

if [ -f /usr/local/share/ca-certificates/NHIRootCA.crt ]; then
  sudo rm /usr/local/share/ca-certificates/NHIRootCA.crt
  sudo update-ca-certificates --fresh
fi

ctr=$(buildah from docker.io/library/alpine:edge)
buildah copy --chmod 0755 "$ctr" nhiicc /usr/local/share/NHIICC/
#apk add --no-cache nss-tools;
buildah run "$ctr" /bin/sh -c '
  apk add --no-cache gcompat ca-certificates openssl pcsc-lite-libs;
  /usr/local/share/NHIICC/regen-certs.sh'

buildah config --cmd /usr/local/share/NHIICC/start.sh "$ctr"
#buildah config --port 7777 "$ctr"

buildah commit "$ctr" localhost:"$port"/nhiicc:"$image_ver"
buildah unshare bash -c '
  mnt=$(buildah mount "$0");
  cp -r $mnt/usr/local/share/NHIICC/cert/NHIRootCA.crt ./;
  buildah unmount "$0"' "$ctr"
buildah rm "$ctr"
buildah tag localhost:"$port"/nhiicc:"$image_ver" localhost:"$port"/nhiicc:latest

sudo cp ./NHIRootCA.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
