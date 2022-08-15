#!/bin/bash

# THIS IS FREE SOFTWARE; SEE LICENSE FOR MORE INFORMATION

# Created 2022, by Lucy Mielke

## Set flags for command output and error halting
set -e
set -x

## mount 
export LFS=/mnt/LFS

# If you want to run that, please change sdb1 to your desired drive
mkdir -pv $LFS
mount -v -t ext4 /dev/sdb1 $LFS 


