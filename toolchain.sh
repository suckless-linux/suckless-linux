#!/bin/sh
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
echo "create target filesystem structure...;"
echo "===================================================================";
mkdir -pv ${SL}/{bin,boot{,grub},dev,{etc/,}opt,home,lib/{firmware,modules},lib64,mnt};
