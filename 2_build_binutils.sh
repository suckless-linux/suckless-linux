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
echo "uncompressing binutils tarball...";
echo "===================================================================";

tar -xf tarballs/binutils-2.38.tar.xz;

mkdir binutils-build;
cd binutils-build/;

echo "===================================================================";
echo "building binutils...";
echo "===================================================================";

../binutils-2.38/configure --prefix=${SL}/cross-tools \
--target=${SL_TARGET} --with-sysroot=${SL} \
--disable-nls --enable-shared --disable-multilib;

make configure-host && make;
ln -sv lib ${SL}/cross-tools/lib64;
make install;

cp -v ../binutils-2.38/include/libiberty.h ${SL}/usr/include;

cd ../;

echo "done";
