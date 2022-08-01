#!/bin/sh


######################################
# script for building suckless-linux #
#         and cross-compiler         #
######################################



echo "===================================================================";
echo "setting variables, creating environment...";
echo "===================================================================";
set +h;
umask 022;
export SL=~/Dokumente/suckless-linux/suckless;
mkdir -pv ${SL};
export LC_ALL=POSIX;
export PATH=${SL}/cross-tools/bin:/bin:/usr/bin;

echo "===================================================================";
echo "create target filesystem structure...";
echo "===================================================================";
mkdir -pv ${SL}/{bin,boot/{,grub},dev,{etc/,}opt,home,lib/{firmware,modules},lib64,mnt};
mkdir -pv ${SL}/{proc,media/{floppy,cdrom},sbin,srv,sys};
mkdir -pv ${SL}/var/{lock,log,mail,run,spool};
mkdir -pv ${SL}/var/{opt,cache,lib/{misc,locate},local};
install -dv -m 0750 ${SL}/root;
install -dv -m 1777 ${SL}{/var,}/tmp;
install -dv ${SL}/etc/init.d;
mkdir -pv ${SL}/usr/{,local/}{bin,include,lib{,64},sbin,src};
mkdir -pv ${SL}/usr/{,local/}share/{doc,info,locale,man};
mkdir -pv ${SL}/usr/{,local/}share/{misc,terminfo,zoneinfo};
mkdir -pv ${SL}/usr/{,local/}share/man/man{1,2,3,4,5,6,7,8};
for dir in ${SL}/usr{,/local}; do
  ln -sv share/{man,doc,info} ${dir}
done;


echo "===================================================================";
echo "creating directory for cross-compilation toolchain...";
echo "===================================================================";
install -dv ${SL}/cross-tools{,/bin};


echo "===================================================================";
echo "use symlink to /proc/mounts to maintain a list of mounted filesystems in /etc/mtab...";
echo "===================================================================";
ln -svf /proc/mounts ${SL}/etc/mtab;


echo "===================================================================";
echo "create /etc/passwd file...";
echo "===================================================================";
cat > ${SL}/etc/passwd<< "EOF"
root::0:0:root:/root:/bin/ash
EOF


echo "===================================================================";
echo "create /etc/group file...";
echo "===================================================================";
cat > ${SL}/etc/group<< "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:4:
daemon:x:6:
disk:x:8:
dialout:x:10:
video:x:12:
utmp:x:13:
usb:x:14:
EOF


echo "===================================================================";
echo "create etc/fstab file...";
echo "===================================================================";
cat > ${SL}/etc/fstab << "EOF"
# file system  mount-point  type   options          dump  fsck
#                                                         order

rootfs          /               auto    defaults        1      1
proc            /proc           proc    defaults        0      0
sysfs           /sys            sysfs   defaults        0      0
devpts          /dev/pts        devpts  gid=4,mode=620  0      0
tmpfs           /dev/shm        tmpfs   defaults        0      0
EOF


echo "===================================================================";
echo "create /etc/profile file...";
echo "===================================================================";
cat > ${SL}/etc/profile << "EOF"
export PATH=/bin:/usr/bin

if [ `id -u` -eq 0 ] ; then
        PATH=/bin:/sbin:/usr/bin:/usr/sbin
        unset HISTFILE
fi


# Set up some environment variables.
export USER=`id -un`
export LOGNAME=$USER
export HOSTNAME=`/bin/hostname`
export HISTSIZE=1000
export HISTFILESIZE=1000
export PAGER='/bin/more '
export EDITOR='/bin/vi'
EOF


echo "===================================================================";
echo "create /etc/hostname file...";
echo "===================================================================";
echo "suckless-live" > ${SL}/etc/HOSTNAME;

echo "===================================================================";
echo "create /etc/issue file...";
echo "===================================================================";
cat > ${SL}/etc/issue<< "EOF"
Suckless Linux 1.2
Kernel \r on \m

EOF

echo "===================================================================";
echo "create /etc/inittab file...";
echo "===================================================================";
cat > ${SL}/etc/inittab<< "EOF"
::sysinit:/etc/rc.d/startup

tty1::respawn:/sbin/getty 38400 tty1
tty2::respawn:/sbin/getty 38400 tty2
tty3::respawn:/sbin/getty 38400 tty3
tty4::respawn:/sbin/getty 38400 tty4
tty5::respawn:/sbin/getty 38400 tty5
tty6::respawn:/sbin/getty 38400 tty6

::shutdown:/etc/rc.d/shutdown
::ctrlaltdel:/sbin/reboot
EOF


echo "===================================================================";
echo "create /etc/mdev.conf file...";
echo "===================================================================";
cat > ${SL}/etc/mdev.conf<< "EOF"
# Devices:
# Syntax: %s %d:%d %s
# devices user:group mode

# null does already exist; therefore ownership has to
# be changed with command
null    root:root 0666  @chmod 666 $MDEV
zero    root:root 0666
grsec   root:root 0660
full    root:root 0666

random  root:root 0666
urandom root:root 0444
hwrandom root:root 0660

# console does already exist; therefore ownership has to
# be changed with command
console root:tty 0600 @mkdir -pm 755 fd && cd fd && for x in 0 1 2 3 ; do ln -sf /proc/self/fd/$x $x; done

kmem    root:root 0640
mem     root:root 0640
port    root:root 0640
ptmx    root:tty 0666

# ram.*
ram([0-9]*)     root:disk 0660 >rd/%1
loop([0-9]+)    root:disk 0660 >loop/%1
sd[a-z].*       root:disk 0660 */lib/mdev/usbdisk_link
hd[a-z][0-9]*   root:disk 0660 */lib/mdev/ide_links

tty             root:tty 0666
tty[0-9]        root:root 0600
tty[0-9][0-9]   root:tty 0660
ttyO[0-9]*      root:tty 0660
pty.*           root:tty 0660
vcs[0-9]*       root:tty 0660
vcsa[0-9]*      root:tty 0660

ttyLTM[0-9]     root:dialout 0660 @ln -sf $MDEV modem
ttySHSF[0-9]    root:dialout 0660 @ln -sf $MDEV modem
slamr           root:dialout 0660 @ln -sf $MDEV slamr0
slusb           root:dialout 0660 @ln -sf $MDEV slusb0
fuse            root:root  0666

# misc stuff
agpgart         root:root 0660  >misc/
psaux           root:root 0660  >misc/
rtc             root:root 0664  >misc/

# input stuff
event[0-9]+     root:root 0640 =input/
ts[0-9]         root:root 0600 =input/

# v4l stuff
vbi[0-9]        root:video 0660 >v4l/
video[0-9]      root:video 0660 >v4l/

# load drivers for usb devices
usbdev[0-9].[0-9]       root:root 0660 */lib/mdev/usbdev
usbdev[0-9].[0-9]_.*    root:root 0660
EOF


echo "===================================================================";
echo "create /boot/grub/grub.cfg file...";
echo "===================================================================";
cat > ${SL}/boot/grub/grub.cfg<< "EOF"

set default=0
set timeout=5

set root=(hd0,1)

menuentry "Suckless Linux 1.2" {
        linux   /boot/vmlinuz-5.18.15 root=/dev/sda1 ro quiet
}
EOF


echo "===================================================================";
echo "initialise logfiles and give proper permissions...";
echo "===================================================================";

touch ${SL}/var/run/utmp ${SL}/var/log/{btmp,lastlog,wtmp};
chmod -v 664 ${SL}/var/run/utmp ${SL}/var/log/lastlog;

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
echo "uncompressing linux tarball...";
echo "===================================================================";

tar -xf tarballs/linux-5.18.15.tar.xz;
cd linux-5.18.15/;

echo "===================================================================";
echo "installing kernel standard header files for the cross-compiler...";
echo "===================================================================";

make mrproper;
#make ARCH=${SL_ARCH} headers_check && \
make ARCH=${SL_ARCH} INSTALL_HDR_PATH=dest headers_install;
cp -rv dest/include/* ${SL}/usr/include;

cd ../;

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


echo "===================================================================";
echo "Uncompressing gcc tarball...";
echo "===================================================================";

cd ../;

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


echo "===================================================================";
echo "uncompressing GLIBC tarball...";
echo "===================================================================";

cd ../;
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

cd ../

echo "===================================================================";
echo "uncompressing busybox tarball...";
echo "===================================================================";

tar -xf tarballs/busybox-2.38.tar.bz2;
cd busybox-2.38/;


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

echo "===================================================================";
echo "Uncompressing linux kernel...";
echo "===================================================================";

tar -xf tarballs/linux-5.18.15.tar.xz;

cd linux-5.18.15/;


echo "===================================================================";
echo "building linux kernel...";
echo "===================================================================";

cp -v /boot/config-$(uname -r) .config;

#make ARCH=${SL_ARCH} \
#CROSS_COMPILE=${SL_TARGET}- x86_64_defconfig;

#make ARCH=${SL_ARCH} \
#CROSS_COMPILE=${SL_TARGET}- menuconfig #allmodconfig;

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


echo "===================================================================";
echo "decompressing CLFS-Bootscripts...";
echo "===================================================================";

tar -xf tarballs/clfs-embedded-bootscripts-1.0-pre5.tar.bz2;

cd clfs-embedded-bootscripts-1.0-pre5;


echo "===================================================================";
echo "configuring and installing target environment...";
echo "===================================================================";

make DESTDIR ${SL}/ install-bootscripts;

ln -sv ../rc.d/startup ${SL}/etc/init.d/rcS;

echo "===================================================================";
echo "installing zlib...";
echo "===================================================================";

cd ../;
tar -xf tarballs/zlib-1.2.11.tar.gz;
cd zlib-1.2.11/;

sed -i 's/-O3/-Os/g' configure;
./configure --prefix=/usr --shared;
make && make DESTDIR=${SL}/ install;

mv -v ${SL}/usr/lib/libz.so.* ${SL}/lib;
ln -svf ../../lib/libz.so.1 ${SL}/usr/lib/libz.so;
ln -svf ../../lib/libz.so.1 ${SL}/usr/lib/libz.so.1;
ln -svf ../lib/libz.so.1 ${SL}/lib64/libz.so.1;


echo "===================================================================";
echo "Installing target image...";
echo "===================================================================";

cd ../;

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
sudo tar cfJ ../suckless-build-20220208-nightly.tar.xz *;
