#!/bin/bash

source mp1.conf
export NO_GIT_UPDATE=1

cd $FENIX
source config/version

source env/setenv.sh -q -s  KHADAS_BOARD=VIM3L LINUX=mainline UBOOT=mainline DISTRIBUTION=Ubuntu DISTRIB_RELEASE=jammy DISTRIB_RELEASE_VERSION=22.04 DISTRIB_TYPE=server DISTRIB_ARCH=arm64 INSTALL_TYPE=SD-USB COMPRESS_IMAGE=no

make uboot-deb

echo "Backup u-boot .deb file to platform files"
rm $PLATFORM/kernelnew/khadas/debs/${DEVICE}/linux-u-boot*.deb
cp build/images/debs/$VERSION/VIM3L/linux-u-boot*.deb ${PLATFORM}/kernelnew/khadas/debs/${DEVICE}/

echo "Populate $PLATFORM with necessary u-boot files"
[ -e "/tmp/u-boot" ] && rm -r /tmp/u-boot
mkdir /tmp/u-boot
dpkg-deb -R $PLATFORM/kernelnew/khadas/debs/${DEVICE}/linux-u-boot* /tmp/u-boot
cp /tmp/u-boot/usr/lib/u-boot/* $PLATFORM/${DEVICE}/u-boot
rm -r /tmp/u-boot

echo "Done..."
