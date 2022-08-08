#!/bin/bash


######################################
# script for building suckless-linux #
#         and cross-compiler         #
######################################



echo "===================================================================";
echo "setting variables, creating environment...";
echo "===================================================================";
set +h;
set -e;
set -x;
umask 022;
export SL=~/suckless-linux/suckless;
mkdir -pv ${SL};
export LC_ALL=POSIX;
export PATH=${SL}/cross-tools/bin:/bin:/usr/bin;


echo "===================================================================";
echo "creating directory for cross-compilation toolchain...";
echo "===================================================================";
install -dv ${SL}/cross-tools{,/bin};

echo "===================================================================";
echo "use symlink to /proc/mounts to maintain a list of mounted filesystems in /etc/mtab...";
echo "===================================================================";


echo "===================================================================";
echo "prepare for building cross-compiler...";
echo "===================================================================";

unset CFLAGS;
unset CXXFLAGS;

export SL_HOST=$(echo ${MACHTYPE} | sed "s/-[^-]*/-cross/");
export SL_TARGET=x86_64-unknown-linux-gnu;
export SL_CPU=k8;
export SL_ARCH=$(echo ${SL_TARGET} | sed -e 's/-.*//' -e 's/i.86/i386/');
export SL_ENDIAN=little;

echo "done";
