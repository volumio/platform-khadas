#!/bin/bash

if [ -z "${DEVICE}" ]; then
    echo "This script can't be run directly. Use device specific scripts instead."
fi

echo "Fetch the pre-compiled Khadas ${DEVICE} device tree overlay module .deb file"
if [ ! -e $DT_OVERLAYS ]; then
   git clone http://github.com/numbqq/dt-overlays-debs --depth=1 $DT_OVERLAYS
else
   cd $DT_OVERLAYS
   git pull
   cd ..
fi   
if [ -f $PLATFORM/kernel-5.15/khadas/debs/${DEVICE}/khadas-${DEVICE}-linux-5.4-dt-overlays* ];then
   rm $PLATFORM/kernel-5.15/khadas/debs/${DEVICE}/khadas-${DEVICE}-linux-5.4-dt-overlays*
fi
echo "... and back it up to the platform folder"
cp $DT_OVERLAYS/jammy/arm64/${DEVICE^^}/khadas-${DEVICE}-linux-5.4-dt-overlays_*.deb $PLATFORM/kernel-5.15/khadas/debs/${DEVICE}/
   
cd $FENIX
source config/version

if [ ! -e build/linux ]; then
   mkdir -p build/linux
   git clone http://github.com/khadas/linux -b khadas-vims-5.15.y build/linux --depth=1
   git clone http://github.com/khadas/common_drivers -b khadas-vims-5.15.y build/linux/common_drivers --depth=1
   cd build/linux
   echo "Backup original Khadas kernel config"
   cp common_drivers/arch/arm64/configs/kvims_defconfig $PLATFORM/kernel-5.15/khadas/configs/common/kvims_defconfig-original
   echo "Replace by our own config"
   cp $PLATFORM/kernel-5.15/khadas/configs/common/kvims_defconfig common_drivers/arch/arm64/configs/
else
   cd build/linux
   echo "Temporary restore backup khadas config"
   cp $PLATFORM/kernel-5.15/khadas/configs/common/kvims_defconfig-original common_drivers/arch/arm64/configs/kvims_defconfig
   git pull
   echo "Replace by our own config"
   cp $PLATFORM/kernel-5.15/khadas/configs/common/kvims_defconfig common_drivers/arch/arm64/configs/
   ls -l common_drivers/arch/arm64/configs/
fi


cd $FENIX
source env/setenv.sh -q -s  KHADAS_BOARD=${DEVICE^^} LINUX=5.15 UBOOT=2019.01 DISTRIBUTION=Ubuntu DISTRIB_RELEASE=jammy DISTRIB_RELEASE_VERSION=22.04 DISTRIB_TYPE=server DISTRIB_ARCH=arm64 INSTALL_TYPE=SD-USB COMPRESS_IMAGE=no

make kernel-clean
make kernel-config

echo "Copying kernel config to platform-khadas/kernel-5.15/khadas/configs/common"
make kernel-saveconfig
cp build/linux/common_drivers/arch/arm64/configs/kvims_defconfig $PLATFORM/kernel-5.15/khadas/configs/common

make kernel-deb

echo "Cleaning previous .deb files from platform-khadas"
rm $PLATFORM/kernel-5.15/khadas/debs/common/linux-dtb*.deb
rm $PLATFORM/kernel-5.15/khadas/debs/common/linux-headers*.deb
rm $PLATFORM/kernel-5.15/khadas/debs/common/linux-image*.deb

echo "Backup new .deb files to platform-khadas"
cp build/images/debs/$VERSION/${DEVICE^^}/linux-dtb*.deb $PLATFORM/kernel-5.15/khadas/debs/common/
cp build/images/debs/$VERSION/${DEVICE^^}/linux-headers*.deb $PLATFORM/kernel-5.15/khadas/debs/common/
cp build/images/debs/$VERSION/${DEVICE^^}/linux-image*.deb $PLATFORM/kernel-5.15/khadas/debs/common/

echo "Done..."
