#!/bin/bash

source vim4.conf

echo "Populate $PLATFORM with necessary platform files"
[ -e "/tmp/linux-image" ] && rm -r /tmp/linux-image
[ -e "/tmp/khadas-dt-overlays" ] && rm -r /tmp/khadas-dt-overlays
[ -e "/tmp/u-boot" ] && rm -r /tmp/u-boot
mkdir /tmp/linux-image
mkdir /tmp/khadas-dt-overlays
mkdir /tmp/u-boot

echo "Get the latest platform/vims-5.15 folder"
cd $PLATFORM
git pull
[ -e vims-5.15 ] && rm -r vims-5.15 && tar xfJ vims-5.15.tar.xz
cd ..

echo "Backup hwpacks to vim4 folder"
mkdir -p $PLATFORM/vims-5.15/hwpacks/
cp -R ${FENIX}/archives/hwpacks/wlan-firmware $PLATFORM/vims-5.15/hwpacks/
cp -R ${FENIX}/archives/hwpacks/bluez $PLATFORM/vims-5.15/hwpacks/

echo "Unpacking boot, lib and dtb from Khadas .deb file..."  
dpkg-deb -R $PLATFORM/kernel-5.15/khadas/debs/common/linux-image*.deb /tmp/linux-image
cp /tmp/linux-image/boot/vmlinuz-* $PLATFORM/vims-5.15/boot/Image
cp /tmp/linux-image/boot/config* $PLATFORM/vims-5.15/boot/
cp -R /tmp/linux-image/lib/modules $PLATFORM/vims-5.15/lib/

mkdir -p $PLATFORM/vims-5.15/boot/dtb/amlogic
cp -R /tmp/linux-image/usr/lib/linux-image*/* $PLATFORM/vims-5.15/boot/dtb/amlogic

echo "Unpacking pre-copmpiled khadas vim4 device tree overlay modules"
[ -e $PLATFORM/vims-5.15/boot/dtb/amlogic/kvim4.dtb.overlays ] && rm -r $PLATFORM/vims-5.15/boot/dtb/amlogic/kvim4.dtb.overlays
dpkg-deb -R $PLATFORM/kernel-5.15/khadas/debs/${DEVICE}/khadas-vim4-linux-5.4-dt-overlays_*.deb /tmp/khadas-dt-overlays
cp -R /tmp/khadas-dt-overlays/boot/overlays/* $PLATFORM/vims-5.15/boot/dtb/amlogic/

echo "Compile renamesound.dts overlay (which, when used, renames AML_AGUGESOUND to AML_AUGESOUND-V1S"
dtc -O dtb -o $PLATFORM/vims-5.15/boot/dtb/amlogic/kvim4.dtb.overlays/renamesound.dtbo $PLATFORM/kernel-5.15/khadas/patches/${DEVICE}/renamesound.dts

echo "Copy Khadas-specific firmware with it"
mkdir -p $PLATFORM/vims-5.15/lib/firmware
cp -R $PLATFORM/vims-5.15/hwpacks/wlan-firmware/* $PLATFORM/vims-5.15/lib/firmware/

echo "Populate ${PLATFORM} with necessary u-boot files"
dpkg-deb -R $PLATFORM/kernel-5.15/khadas/debs/${DEVICE}/linux-u-boot* /tmp/u-boot
mkdir -p $PLATFORM/vims-5.15/u-boot/${DEVICE}
cp /tmp/u-boot/usr/lib/u-boot/* $PLATFORM/vims-5.15/u-boot/${DEVICE}/

rm -r /tmp/u-boot
rm -r /tmp/linux-image
rm -r /tmp/khadas-dt-overlays

cd $PLATFORM
tar cvfJ vims-5.15.tar.xz ./vims-5.15

echo "Done"
