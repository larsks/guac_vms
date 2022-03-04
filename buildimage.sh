#!/bin/sh

BACKING_STORE=/var/lib/libvirt/images/Fedora-Cloud-Base-35-1.2.x86_64.raw
BACKING_FORMAT=raw
IMAGE=fedora.qcow2
IMAGE_SIZE=7G

set -o errexit

rm -f $IMAGE

echo "* Create working image"
qemu-img create -b $BACKING_STORE -F $BACKING_FORMAT -f qcow2 $IMAGE $IMAGE_SIZE

echo "* Resizing root filesystem"
virt-customize -a $IMAGE --run-command "growpart /dev/sda 5" --run-command "btrfs filesystem resize max /"

echo "* Customizing image"
virt-customize -a $IMAGE --run configure-image.sh --selinux-relabel

echo "* Running virt-sysprep on image"
virt-sysprep -a $IMAGE --root-password locked:disabled --selinux-relabel

echo "* Rebasing image"
qemu-img rebase -f qcow2 -F qcow2 -b "" $IMAGE

echo "* Creating test image"
rm -f boot-$IMAGE
qemu-img create -b $IMAGE -f qcow2 -F qcow2 boot-$IMAGE
