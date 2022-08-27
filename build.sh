#!/bin/bash

# THIS IS FREE SOFTWARE; SEE LICENSE FOR MORE INFORMATION

# Created 2022, by Lucy Mielke

## Set flags for command output and error halting
set -e
set -x

## mount and set env vars
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE

## If you want to run that, please change sdb1 to your desired drive
mkdir -pv $LFS
mount -v -t ext4 /dev/sdb1 $LFS

mkdir -v $LFS/sources

cp -v wget-list $LFS/wget-list
cp -v md5sums $LFS/sources/md5sums

## download all neccessary tarballs using the wget-list
# source: 
# https://www.linuxfromscratch.org/lfs/view/stable-systemd/wget-list

wget --input-file=wget-list --continue --directory-prefix=$LFS/sources

## check md5 sums
pushd sources/
md5sum -c md5sums
popd

## create limited directory layout
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
  ln -sv usr/$i $LFS/$i
done

case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64 ;;
esac

mkdir -pv tools

## prepare for compilation 
export MAKEFLAGS='-j4'
