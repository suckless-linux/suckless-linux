#!/bin/bash

set -e;
set -x;

git clone https://gitlab.archlinux.org/archlinux/archiso.git;
sudo ./archiso/archiso/mkarchiso -v -w suckless-tmp/ config/;


