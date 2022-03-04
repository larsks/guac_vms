#!/bin/sh

BACKING_STORE=/var/lib/libvirt/images/Fedora-Cloud-Base-35-1.2.x86_64.raw
BACKING_FORMAT=raw
IMAGE=fedora.qcow2
IMAGE_SIZE=5G

set -o errexit

rm -f $IMAGE
qemu-img create -b $BACKING_STORE -F $BACKING_FORMAT -f qcow2 $IMAGE $IMAGE_SIZE
#virt-customize -a $IMAGE --run-command "growpart /dev/sda 5" --run-command "btrfs filesystem resize max /"
virt-customize -a $IMAGE --run configure-image.sh --selinux-relabel
virt-sysprep -a $IMAGE --root-password locked:disabled --selinux-relabel
