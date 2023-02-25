#!/bin/bash

source mp1.conf

echo "Populate $PLATFORM with necessary platform files"
[ -e "/tmp/linux-image" ] && rm -r /tmp/linux-image
[ -e "/tmp/linux-firmware" ] && rm -r /tmp/linux-firmware

mkdir /tmp/linux-image
mkdir /tmp/linux-firmware

echo "Get the latest platform/${DEVICE} folder" 
cd $PLATFORM
git pull
[ -e ${DEVICE} ] && rm -r ${DEVICE} && tar xfJ ${DEVICE}.tar.xz 
cd ..

echo "Unpacking boot, lib and dtb from Khadas .deb file..."  
dpkg-deb -R $PLATFORM/kernelnew/khadas/debs/${DEVICE}/linux-image*.deb /tmp/linux-image
cp /tmp/linux-image/boot/vmlinuz-* $PLATFORM/${DEVICE}/boot/Image
cp /tmp/linux-image/boot/config* $PLATFORM/${DEVICE}/boot/
cp -R /tmp/linux-image/lib/modules $PLATFORM/${DEVICE}/lib/
cp -R /tmp/linux-image/usr/lib/linux-image*/amlogic/* $PLATFORM/${DEVICE}/boot/dtb/amlogic/

echo "Unpacking firmware and merge Khadas-specific firmware with it"
dpkg-deb -R $PLATFORM/kernelnew/khadas/debs/common/armbian-firmware*.deb /tmp/linux-firmware
cp -R /tmp/linux-firmware/lib/firmware $PLATFORM/${DEVICE}/lib/
cp -R $PLATFORM/${DEVICE}/hwpacks/wlan-firmware/* $PLATFORM/${DEVICE}/lib/firmware

rm -r /tmp/linux-image
rm -r /tmp/linux-firmware

cd $PLATFORM
tar cvfJ ${DEVICE}.tar.xz ./${DEVICE}

echo "Done"
