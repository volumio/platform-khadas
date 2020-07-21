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
2020-03-23: bump to Khadas 4.9.203 kernel, incl. usb audio quirks patch/ add squashfs decomp parallelisation    
2020-03-23: OTA updates: fixed boot.ini and env.txt  
2020-03-23: Due to kernel 4.9.206: Soundcard AML-AUGESOUND changed to AML-AUGESOUND-V.   
2020-03-23: Correct partition name variables as a final OTA fix.  
2020-04-01: Updated Khadas u-boot scripts and boot.ini  
2020-04-03: Optimized boot parameter handling, adding boot logo  
2020-04-13: Identical AML-AUGESOUND-V config for VIM3 and VIM3L  
2020-04-14: Optimized cpu frequency scaling with new rc.local script
2020-04-14: Optimized IRQ cpu affinity  
2020-04-26: Temporary fix for reboot crash/ enabling Khadas remote  
2020-04-27: Updated Auto Installer HOW-TO
2020-04-27: Temporary disable mcu poweroff for VIM3L/mp1  
2020-07-21: Replaced VIM3L u-boot with the latest from kresc  





