#/bin/bash

source mp1.conf
export NO_GIT_UPDATE=1

cd $FENIX
source config/version

echo "Re-apply the last mofified kernel configuration"  
if [ -f "${PLATFORM}/kernelnew/khadas/configs/${DEVICE}/kvims_defconfig" ] && [ -e "${FENIX}/build/linux" ]; then
  cp ${PLATFORM}/kernelnew/khadas/configs/${DEVICE}/kvims_defconfig ${FENIX}/build/linux/arch/arm64/configs/kvims_defconfig  
fi
  
source env/setenv.sh -q -s  KHADAS_BOARD=VIM3L LINUX=mainline UBOOT=mainline DISTRIBUTION=Ubuntu DISTRIB_RELEASE=jammy DISTRIB_RELEASE_VERSION=22.04 DISTRIB_TYPE=server DISTRIB_ARCH=arm64 INSTALL_TYPE=SD-USB COMPRESS_IMAGE=no

make kernel-clean
make kernel-config
make kernel-deb
echo "Copying kernel config to platform-mp/configs/${DEVICE}"
cp build/linux/.config $PLATFORM/kernelnew/khadas/configs/${DEVICE}/kvims_defconfig

echo "Removing old kernel .deb files from platform-mp/debs"
rm $PLATFORM/kernelnew/khadas/debs/${DEVICE}/linux-dtb*.deb
rm $PLATFORM/kernelnew/khadas/debs/${DEVICE}/linux-headers*.deb
rm $PLATFORM/kernelnew/khadas/debs/${DEVICE}/linux-image*.deb

echo "Copying the new .deb files to platform-mp/debs"
cp build/images/debs/${VERSION}/VIM3L/linux-dtb*.deb $PLATFORM/kernelnew/khadas/debs/${DEVICE}/
cp build/images/debs/${VERSION}/VIM3L/linux-headers*.deb $PLATFORM/kernelnew/khadas/debs/${DEVICE}/
cp build/images/debs/${VERSION}/VIM3L/linux-image*.deb $PLATFORM/kernelnew/khadas/debs/${DEVICE}/


echo "Done..."
