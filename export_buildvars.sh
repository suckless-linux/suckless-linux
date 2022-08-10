#!/bin/sh

#######################################
# script for exporting important vars # 
#######################################

echo "===================================================================";
echo "exporting required variables...";
echo "===================================================================";


set +h;
umask 022;
export SL=~/Dokumente/suckless-linux/suckless;
export LC_ALL=POSIX;
export PATH=${SL}/cross-tools/bin:/bin:/usr/bin;
unset CFLAGS;
unset CXXFLAGS;
export SL_HOST=$(echo ${MACHTYPE} | sed "s/-[^-]*/-cross/");
export SL_TARGET=x86_64-unknown-linux-gnu;
export SL_CPU=k8;
export SL_ARCH=$(echo ${SL_TARGET} | sed -e 's/-.*//' -e 's/i.86/i386/');
export SL_ENDIAN=little;
export CC="${SL_TARGET}-gcc";
export CXX="${SL_TARGET}-g++";
export CPP="${SL_TARGET}-gcc -E";
export AR="${SL_TARGET}-ar";
export AS="${SL_TARGET}-as";
export LD="${SL_TARGET}-ld";
export RANLIB="${SL_TARGET}-ranlib";
export READELF="${SL_TARGET}-readelf";
export STRIP="${SL_TARGET}-strip";

