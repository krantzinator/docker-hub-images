#!/usr/bin/env bash

set -e

base="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ $# -ne 1 ]]; then
    echo "You must set a version number"
    echo "./deploy.sh <packer version>"
    exit 1
fi

version=$1
dockerfile_version=$(grep PACKER_VERSION= ${base}/Dockerfile-light | cut -d= -f2)

if [[ $version != $dockerfile_version ]]; then
    echo "Version mismatch in 'Dockerfile-light'"
    echo "found ${dockerfile_version}, expected ${version}."
    echo "Make sure the versions are correct."
    exit 1
fi

echo "Updating alpine releases"
docker pull alpine
docker pull golang:alpine

echo "Building docker images for packer ${version}..."
docker build -f "${base}/Dockerfile-full" -t krantzinator/packer:full .
docker build -f "${base}/Dockerfile-light" -t krantzinator/packer:light .
docker tag krantzinator/packer:light krantzinator/packer:${version}
docker tag krantzinator/packer:light krantzinator/packer:latest
docker tag krantzinator/packer:full krantzinator/packer:full-${version}

echo "Uploading docker images for packer ${version}..."
docker push krantzinator/packer:${version}
docker push krantzinator/packer:full-${version}
docker push krantzinator/packer:latest
docker push krantzinator/packer:light
docker push krantzinator/packer:full
