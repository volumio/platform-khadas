#!/bin/bash

source vim1s.conf

echo "Populate $PLATFORM with necessary platform files"
[ -e "/tmp/linux-image" ] && rm -r /tmp/linux-image
[ -e "/tmp/linux-firmware" ] && rm -r /tmp/linux-firmware
[ -e "/tmp/khadas-dt-overlays" ] && rm -r /tmp/khadas-dt-overlays
mkdir /tmp/linux-image
mkdir /tmp/linux-firmware
mkdir /tmp/khadas-dt-overlays

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

echo "Unpacking pre-copmpiled khadas vim1s device tree overlay modules"
[ -e $PLATFORM/${DEVICE}/boot/dtb/amlogic/kvim1s.dtb.overlays ] && rm -r $PLATFORM/${DEVICE}/boot/dtb/amlogic/kvim1s.dtb.overlays
dpkg-deb -R $PLATFORM/kernelnew/khadas/debs/${DEVICE}/khadas-vim1s-linux-5.4-dt-overlays_*.deb /tmp/khadas-dt-overlays
cp -R /tmp/khadas-dt-overlays/boot/overlays/* $PLATFORM/${DEVICE}/boot/dtb/amlogic/

echo "Compile renamesound.dts overlay (which, when used, renames AML_AGUGESOUND to AML_AUGESOUND-V1S"
dtc -O dtb -o $PLATFORM/${DEVICE}/boot/dtb/amlogic/kvim1s.dtb.overlays/renamesound.dtbo $PLATFORM/kernelnew/khadas/patches/${DEVICE}/renamesound.dts
  
echo "Unpacking firmware and merge Khadas-specific firmware with it"
dpkg-deb -R $PLATFORM/kernelnew/khadas/debs/common/armbian-firmware*.deb /tmp/linux-firmware
cp -R /tmp/linux-firmware/lib/firmware $PLATFORM/${DEVICE}/lib/
cp -R $PLATFORM/${DEVICE}/hwpacks/wlan-firmware/* $PLATFORM/${DEVICE}/lib/firmware

rm -r /tmp/linux-image
rm -r /tmp/linux-firmware
rm -r /tmp/khadas-dt-overlays

cd $PLATFORM
tar cvfJ ${DEVICE}.tar.xz ./${DEVICE}

echo "Done"
