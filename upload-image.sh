#!/bin/sh

DVNAME=shaw-virtual-desktop
IMAGE=fedora.qcow2
IMAGE_SIZE=7Gi

tmpfile=$(mktemp imageXXXXXX.raw)
trap 'rm -f $tmpfile' EXIT

kubectl delete dv "$DVNAME"
kubectl virt image-upload dv "$DVNAME" --size="$IMAGE_SIZE" --image-path=$IMAGE
