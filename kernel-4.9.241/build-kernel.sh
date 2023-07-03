
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export PATH=/opt/toolchains/gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu/bin/:$PATH

cd $HOME/linux-4.9.y
echo "Cleaning and preparing .config"

cp /media/nas/khadas/vims/khadas-vims_defconfig arch/arm64/configs/
make clean
make khadas-vims_defconfig
make menuconfig
cp .config /media/nas/khadas/vims/khadas-vims_defconfig

echo "Compiling dts, image and modules"
make -j12 Image dtbs modules

echo "Saving to khadas/vims on NAS"
cp arch/arm64/boot/Image /media/nas/khadas/vims/boot
cp arch/arm64/boot/dts/amlogic/kvim_linux.dtb /media/nas/khadas/vims/boot/dtb
cp arch/arm64/boot/dts/amlogic/kvim3l_linux.dtb /media/nas/khadas/vims/boot/dtb
kver=`make kernelrelease`-`date +%Y.%m.%d-%H.%M`
rm /media/nas/khadas/vims/boot/config*
cp arch/arm64/configs/khadas-vims_defconfig /media/nas/khadas/vims/boot/config-${kver}
rm -r /media/nas/khadas/vims/lib/modules
make modules_install ARCH=arm64 INSTALL_MOD_PATH=/media/nas/khadas/vims/

echo "Compressing khadas/vims"
cd /media/nas/khadas
tar cvfJ vims.tar.xz ./vims

