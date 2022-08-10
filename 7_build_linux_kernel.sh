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
echo "prepare for building cross-compiler...";
echo "===================================================================";

#unset CFLAGS;
#unset CXXFLAGS;

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
echo "Uncompressing linux kernel...";
echo "===================================================================";

tar -xf tarballs/linux-5.18.15.tar.xz;

cd linux-5.18.15/;


echo "===================================================================";
echo "building linux kernel...";
echo "===================================================================";

#cp -v /boot/config-$(uname -r) .config;
cp -v ../kernel-config .config;

#make ARCH=${SL_ARCH} \
#CROSS_COMPILE=${SL_TARGET}- oldconfig;

#make ARCH=${SL_ARCH} \
#CROSS_COMPILE=${SL_TARGET}- prepare;

make ARCH=${SL_ARCH} \
CROSS_COMPILE=${SL_TARGET}-;

make ARCH=${SL_ARCH} \
  CROSS_COMPILE=${SL_TARGET}- \
  INSTALL_MOD_PATH=${SL} modules_install;

cp -v arch/x86/boot/bzImage ${SL}/boot/vmlinuz-5.18.15;
cp -v System.map ${SL}/boot/System.map-5.18.15;
cp -v .config ${SL}/boot/config-5.18.15;

${SL}/cross-tools/bin/depmod.pl \
  -F ${SL}/boot/System.map-5.18.15 \
  -b ${SL}/lib/modules/5.18.15;

cd ../;

echo "done";
