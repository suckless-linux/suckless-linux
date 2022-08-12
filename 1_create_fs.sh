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
unset CFLAGS;
unset CXXFLAGS;

export SL_HOST=$(echo ${MACHTYPE} | sed "s/-[^-]*/-cross/");
export SL_TARGET=x86_64-unknown-linux-gnu;
export SL_CPU=k8;
export SL_ARCH=$(echo ${SL_TARGET} | sed -e 's/-.*//' -e 's/i.86/i386/');
export SL_ENDIAN=little;


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
        linux   /boot/vmlinuz-5.18.15 root=UUID=a93989cd-b5dc-4cca-b746-80b882a9f08a ro quiet
}
EOF


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
