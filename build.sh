#!/bin/bash

# THIS IS FREE SOFTWARE; SEE LICENSE FOR MORE INFORMATION

# Created 2022, by Lucy Mielke

## Set flags for command output and error halting
set -e
set -x

## mount 
export LFS=/mnt/lfs

## If you want to run that, please change sdb1 to your desired drive
mkdir -pv $LFS
mount -v -t ext4 /dev/sdb1 $LFS


## download all neccessary tarballs using the wget-list
# source: 
# https://www.linuxfromscratch.org/lfs/view/stable-systemd/wget-list

wget --input-file=wget-list --continue --directory-prefix=$(pwd)/sources

## check md5 sums
pushd sources/
md5sum -c md5sums
popd


