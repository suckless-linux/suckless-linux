#!/bin/bash


######################################
# script for building suckless-linux #
#         and cross-compiler         #
######################################



echo "===================================================================";
echo "setting variables, creating environment...";
echo "===================================================================";
set +h;
umask 022;
export SL=~/suckless-linux/suckless;
mkdir -pv ${SL};
export LC_ALL=POSIX;
export PATH=${SL}/cross-tools/bin:/bin:/usr/bin;



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

echo "===================================================================";
echo "Setting environment vars....";
echo "===================================================================";

export CC="${SL_TARGET}-gcc";
export CXX="${SL_TARGET}-g++";
export CPP="${SL_TARGET}-gcc -E";
export AR="${SL_TARGET}-ar";
export AS="${SL_TARGET}-as";
export LD="${SL_TARGET}-ld";
export RANLIB="${SL_TARGET}-ranlib";
export READELF="${SL_TARGET}-readelf";
export STRIP="${SL_TARGET}-strip";


echo "===================================================================";
echo "uncompressing busybox tarball...";
echo "===================================================================";

tar -xf tarballs/busybox-1.35.0.tar.bz2;
cd busybox-1.35.0/;


echo "===================================================================";
echo "building busybox...";
echo "===================================================================";

make CROSS_COMPILE="${SL_TARGET}-" defconfig;
#make CROSS_COMPILE="${SL_TARGET}-" menuconfig;

make CROSS_COMPILE="${SL_TARGET}-";
make CROSS_COMPILE="${SL_TARGET}-" \
CONFIG_PREFIX="${SL}" install;

cp -v examples/depmod.pl ${SL}/cross-tools/bin;
chmod 755 ${SL}/cross-tools/bin/depmod.pl;

cd ../;
echo "done";
