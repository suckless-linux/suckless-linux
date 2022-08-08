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
echo "building final gcc...";
echo "===================================================================";

mkdir gcc-build;
cd gcc-build/;

AR=ar LDFLAGS="-Wl,-rpath,${SL}/cross-tools/lib" \
../gcc-12.1.0/configure --prefix=${SL}/cross-tools \
--build=${SL_HOST} --target=${SL_TARGET} \
--host=${SL_HOST} --with-sysroot=${SL} \
--disable-nls --enable-shared \
--enable-languages=c,c++ --enable-c99 \
--enable-long-long \
--with-mpfr-include=$(pwd)/../gcc-12.1.0/mpfr/src \
--with-mpfr-lib=$(pwd)/mpfr/src/.libs \
--disable-multilib --with-arch=${SL_CPU};
make && make install;

cp -v ${SL}/cross-tools/${SL_TARGET}/lib64/libgcc_s.so.1 ${SL}/lib64;

cd ../;

echo "done";

