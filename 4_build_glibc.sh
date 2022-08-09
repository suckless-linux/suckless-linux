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
echo "uncompressing GLIBC tarball...";
echo "===================================================================";

tar -xf tarballs/glibc-2.35.tar.xz;

mkdir glibc-build;
cd glibc-build/;

echo "===================================================================";
echo "Configuring build flags...";
echo "===================================================================";

echo "libc_cv_forced_unwind=yes" > config.cache;
echo "libc_cv_c_cleanup=yes" >> config.cache;
echo "libc_cv_ssp=no" >> config.cache;
echo "libc_cv_ssp_strong=no" >> config.cache;

echo "===================================================================";
echo "building glibc...";
echo "===================================================================";

BUILD_CC="gcc" CC="${SL_TARGET}-gcc" \
AR="${SL_TARGET}-ar" \
RANLIB="${SL_TARGET}-ranlib" CFLAGS="-O2" \
../glibc-2.35/configure --prefix=/usr \
--host=${SL_TARGET} --build=${SL_HOST} \
--disable-profile --enable-add-ons --with-tls \
--enable-kernel=2.6.32 --with-__thread \
--with-binutils=${SL}/cross-tools/bin \
--with-headers=${SL}/usr/include \
--cache-file=config.cache;

make && make install_root=${SL}/ install;

cd ../;

echo "done";
