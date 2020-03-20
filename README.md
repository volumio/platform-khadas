# platform-khadas
Contains all the khadas-specific kernel and build files

kernel: http://github.com/khadas/linux  
branch: khadas-vims-4.9  

uboot: https://github.com/hyphop/khadas-uboot-spi/releases/tag/vims  
alternative: http://github.com/khadas/u-boot  

hwpacks and other: http://github.com/khadas/fenix  

patches: see usb-audio patch in this repo   
kernel build: see script in this repo plus kernel config in vims.tar.xz  

Credits: @hyphop (khadas) and @balbes150 (volumio, armbian, khadas) for some important pointers

2019-11-16: Initial /gkkpch  
2019-11-17: fixed a utf-8 issue with mounting a cifs device  
2019-12-14: add dtb's for Khadas VIM2 & VIM3  
2019-12-16: modified dtb's for audio out, added asound.state for AML_MESONAUDIO/ AML_AUGESOUND
2020-03-10: rename uboot files to support Krescue setup
2020-03-20: add main-line uboot and modified UUID registration (add env.txt instead of using boot.ini)
