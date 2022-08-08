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
echo "Uncompressing gcc tarball...";
echo "===================================================================";



tar -xf tarballs/gcc-12.1.0.tar.xz;

echo "===================================================================";
echo "uncompressing some dependencies...";
echo "===================================================================";

tar xjf tarballs/gmp-6.2.1.tar.bz2;
mv gmp-6.2.1 gcc-12.1.0/gmp;
tar xJf tarballs/mpfr-4.1.0.tar.xz;
mv mpfr-4.1.0 gcc-12.1.0/mpfr;
tar xzf tarballs/mpc-1.2.1.tar.gz;
mv mpc-1.2.1 gcc-12.1.0/mpc;

mkdir gcc-static;
cd gcc-static/;

echo "===================================================================";
echo "building statically linked gcc...";
echo "===================================================================";

AR=ar LDFLAGS="-Wl,-rpath,${SL}/cross-tools/lib" \
../gcc-12.1.0/configure --prefix=${SL}/cross-tools \
--build=${SL_HOST} --host=${SL_HOST} \
--target=${SL_TARGET} \
--with-sysroot=${SL}/target --disable-nls \
--disable-shared \
--with-mpfr-include=$(pwd)/../gcc-12.1.0/mpfr/src \
--with-mpfr-lib=$(pwd)/mpfr/src/.libs \
--without-headers --with-newlib --disable-decimal-float \
--disable-libgomp --disable-libmudflap --disable-libssp \
--disable-threads --enable-languages=c,c++ \
--disable-multilib --with-arch=${SL_CPU};

make all-gcc all-target-libgcc && \
make install-gcc install-target-libgcc;

ln -vs libgcc.a `${SL_TARGET}-gcc -print-libgcc-file-name | sed 's/libgcc/&_eh/'`;

cd ../;

echo "done";



