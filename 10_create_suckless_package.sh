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
echo "Installing target image...";
echo "===================================================================";


cp -rf ${SL}/ ${SL}-copy;
rm -rfv ${SL}-copy/cross-tools;
rm -rfv ${SL}-copy/usr/src/*;

FILES="$(ls ${SL}-copy/usr/lib64/*.a)";
for file in $FILES; do
  rm -f $file;
done;

find ${SL}-copy/{,usr/}{bin,lib,sbin} -type f -exec sudo strip --strip-debug '{}' ';';
find ${SL}-copy/{,usr/}lib64 -type f -exec sudo strip --strip-debug '{}' ';';

sudo chown -R root:root ${SL}-copy;
sudo chgrp 13 ${SL}-copy/var/run/utmp ${SL}-copy/var/log/lastlog;
sudo mknod -m 0666 ${SL}-copy/dev/null c 1 3;
sudo mknod -m 0600 ${SL}-copy/dev/console c 5 1;
sudo chmod 4755 ${SL}-copy/bin/busybox;

echo "===================================================================";
echo "packaging OS-image...";
echo "===================================================================";

cd ${SL}-copy/;
sudo tar cfJ ../suckless-nightly.tar.xz *;
