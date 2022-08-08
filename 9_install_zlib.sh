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
echo "installing zlib...";
echo "===================================================================";
tar -xf tarballs/zlib-1.2.11.tar.gz;
cd zlib-1.2.11/;

sed -i 's/-O3/-Os/g' configure;
./configure --prefix=/usr --shared;
make && make DESTDIR=${SL}/ install;

mv -v ${SL}/usr/lib/libz.so.* ${SL}/lib;
ln -svf ../../lib/libz.so.1 ${SL}/usr/lib/libz.so;
ln -svf ../../lib/libz.so.1 ${SL}/usr/lib/libz.so.1;
ln -svf ../lib/libz.so.1 ${SL}/lib64/libz.so.1;

cd ../;

echo "done";
