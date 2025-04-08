#!/bin/bash

source vim4.conf
export NO_GIT_UPDATE=1


cd $FENIX
source config/version

source env/setenv.sh -q -s  KHADAS_BOARD=${DEVICE^^} LINUX=5.15 UBOOT=2019.01 DISTRIBUTION=Ubuntu DISTRIB_RELEASE=jammy DISTRIB_RELEASE_VERSION=22.04 DISTRIB_TYPE=server DISTRIB_ARCH=arm64 INSTALL_TYPE=SD-USB COMPRESS_IMAGE=no

make uboot-deb

echo "Backup u-boot .deb file to platform files"
rm $PLATFORM/kernel-5.15/khadas/debs/${DEVICE}/linux-u-boot*.deb || true
cp build/images/debs/$VERSION/${DEVICE^^}/linux-u-boot*.deb ${PLATFORM}/kernel-5.15/khadas/debs/${DEVICE}/

echo "Done..."
