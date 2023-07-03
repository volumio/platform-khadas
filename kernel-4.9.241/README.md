# **platform-khadas with vendor kernel**
Contains all the khadas-specific kernel and build files

## **VIM1, VIM2 and VIM3 are no longer supported**
They are removed from the u-boot boot script.

## **Resources**
kernel: **http://github.com/volumio/linux-mp1**  
(which is based on http://github.com/khadas/linux, branch "khadas-vims-4.9.206")

uboot: http://github.com/khadas/u-boot  
(Build with http://github.com/khadas/fenix)  

Alternative location: https://github.com/hyphop/khadas-uboot-spi/releases/tag/vims  
Board-specific root additions (hwpacks and other): http://github.com/khadas/fenix


## **Khadas Kernel**

### **ESS driver**
  
The ES90x8Q2M driver sources have been been inserted into the kernel source tree.  
It compiles, but it is not used as it does not fit the current Khadas audio bus requirements.  
\<**Some other interface was used to change volume, document to be completed by a core team member**>  

### **VIM3L device tree**
**General VIM dtb's**  
We still use copies of decompiled dtb files, originally sent to us by Khadas.
This is unfortunate as it makes changes more difficult/ complex.
We still need to compile/decompile the original dts files, compare them to the Khadas versions to see where the differences are nowadays and reflect them in the current dts.  
I guess, after a number of corrections (since start of the VIM porting), differences are very small, it probably only concerns the 192Kbps issue with I2S.

**Adding more USB Audio DSD devices**  
The Khadas vendor-based 4.9 kernel is not up-to-date with the latest DSD direct capable USB Audio devices.  
Add those which were not included yet (take them from an LTS kernel like 5.10).

## **Kernel compilation**
Ensure you have the platform-khadas folder ready as documented above.  
The kernel build process is supported by a script called build-kernel.sh.  
After compiling the kernel, it will also copy the relevant files into the platform-khadas folder and renew vims.tar.xz.  

**Kernel config**  
The configuration file can be found in the root of platform-khadas/vims (decompress vims.tar.xz when needed, but never push the decompressed "vims" folder to the platform files).    
Note, it is copied from there in the kernel build script.

**Before you start compiling**  
Make sure you have the platform-khadas repo cloned, when present, always do a pull for the latest version.  
In case you have a new ```vims.tar.xz```, remove the existing vims folder and decompress the new ```vims.tar.xz```
```
rm -r vims
tar xfJ vims.tar.xz
```
**Toolchain**  
You need ```gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu``` for compiling.

**Sample build script**  
Make sure the current **platform-khadas** folder is referred to as PLATFORMDIR.
Make sure the current kernel source location is referred to as KERNELDIR.  
Insert the path to your compiler

``` 
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export PATH=/opt/toolchains/gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu/bin/:$PATH
export INSTALL_MOD_STRIP=1 
KERNELDIR=<location of cloned linux-mp1>
PLATFORMDIR=<location of khadas-platform>

cd $KERNELDIR
echo "Cleaning and preparing .config"

cp $PLATFORMDIR/vims/khadas-vims_defconfig arch/arm64/configs/
make clean

make khadas-vims_defconfig
make menuconfig
cp .config $PLATFORMDIR/vims/khadas-vims_defconfig

echo "Compressing the kernel sources"
git archive --format=tar.gz --prefix linux-4.9.206/ -v -o $PLATFORMDIR/`date +%Y.%m.%d-%H.%M`-linux4.9.206.tar.gz khadas-vims-4.9.y

echo "Compiling dts, image and modules"
make -j12 Image dtbs modules

echo "Saving to khadas/vims on NAS"
cp arch/arm64/boot/Image $PLATFORMDIR/vims/boot
cp arch/arm64/boot/dts/amlogic/kvim_linux.dtb $PLATFORMDIR/vims/boot/dtb
cp arch/arm64/boot/dts/amlogic/kvim2_linux.dtb $PLATFORMDIR/vims/boot/dtb
cp arch/arm64/boot/dts/amlogic/kvim3_linux.dtb $PLATFORMDIR/vims/boot/dtb
cp arch/arm64/boot/dts/amlogic/kvim3l_linux.dtb $PLATFORMDIR/vims/boot/dtb
cp arch/arm64/boot/dts/amlogic/kvim3l_primo_linux.dtb $PLATFORMDIR/vims/boot/dtb

kver=`make kernelrelease`-`date +%Y.%m.%d-%H.%M`
rm $PLATFORMDIR/vims/boot/config*
cp arch/arm64/configs/khadas-vims_defconfig $PLATFORMDIR/vims/boot/config-${kver}
rm -r $PLATFORMDIR/vims/lib/modules
make modules_install ARCH=arm64 INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=$PLATFORMDIR/vims/

echo "Compressing $PLATFORMDIR/vims"
cd $PLATFORMDIR
tar cvfJ vims.tar.xz ./vims
``` 
 
Please note the vim, vim2 and vim3 dtb's. You do not need these, VIM1/2/3 are no longer supported. 

## **U-boot compilation**
This is a little trickier, the compilation was done using the Khadas 'fenix' repo at https:/github.com/khadas/fenix.  
Follow the instructions for *legacy* u-boot.  
Mainline u-boot will not work!  

## **Image support documentation**

**Initialise New Batch of VIM3L devices**  
- use serial console
- plug power
- interrupt boot and wait for kvim3l prompt
- erase emmc with 'store init 3'
- unplug power
- insert SD card with installer
- press and hold POWER_KEY
- plug in power
- wait until LED is blinking, release the POWER_KEY

**MP1 build script**  
See http://github.com/volumio/volumio3-os/recipes/devices

**Platform Files**  
Start with a current copy of the "platform-khadas/vims" folder (from the volumio repo)  
This folder is used by the build-kernel.sh script, which copies the relevant files into their correct location as used by the mp1 build script.

- Clone the https://github.com/volumio/platform-khadas repo (--depth 1 will do).
- In the "platform-khadas" folder, unpack archive vims.tar.xz  

This should give you the "platform-khadas/vims" folder.

vims.tar.xz will be rebuilt at the end of the build-kernel.sh script.  
This copy of the new khadas platform files should be pushed to the https://github.com/volumio/platform-khadas repo.

**Contents of platform-khadas subfolders**  
(Used in the MP1 build script(s)  
```boot```
- ```/dtb```  
folder with relevant dtb's for khadas devices, including oem versions (e.g. primo)
- ```aml_autoscript.cmd```  
holds a copy of boot.ini, compiled to aml_autopscript, which allows boot from SD on a factory-flashed android emmc. Do not edit!
- ```boot.ini```  
standard boot script, used to boot a volumio image. Do not edit!
- ```env.txt```  
read by boot.ini and aml_autoscript, standard boot parameters settings, do not edit. User customization belongs in env.user.txt
- ```env.system.txt```  
used to add volumio custom boot parameters, it overrides params from boot.ini. 
Only edit commented params when needed.  
Do not touch LABEL and UUID lines.  
 
Refer to the mp1.sh recipe for more info, it uses this template:
```
## SYSTEM ENV
## PLZ DONT CHANGE THIS FILE

#bootpart=LABEL=
#bootpart=UUID=
#imgpart=LABEL=
#imgpart=UUID=
#datapart=LABEL=
#datapart=UUID=


# append to the end bootargs
BOOTARGS_USER=loglevel=0 quiet splash bootdelay=1
UUIDCONFIG=env.system.txt 

# setup custom dtb kernel initrd files
#
# DTB=vim.dtb
# UBOOT_KERNEL=Image
# UBOOT_UINITRD=uInitrd
```

- ```env.user.txt```  
This should be used for user-specific customization, it will not be touched by OTA. Overrides boot parameters which do not occur in env.txt or env.system.txt
This file should also contain the modified DTB line in case it needs to be persistent (survives an OTA). In that case remove it from env.system.txt  

```etc```  
- ```systemd```  
Contains a VIM3l-specific version of system-halt.service, avoiding an issue with poweroff and reboot.  
Verify periodically (after a kernel update) whether this is still necessary.  
- ```triggerhappy```  
holds the IR remote definitions for triggerhappy
- ```fw_env.config``` (unused)  
- ```rc.local```  
Contains the default rc.local VIM optimization settings
- ```rc.local.mp1```  
Contains the mp1-specific rc.local VIM optimization settings

```hwpacks```  
(from the https://github.com/khadas/fenix repo)

- ```bluez```  
VIM broadcom bluetooth patches  
- ```video-firmware``` (unused)
- ```wlan-firmware```  
Broadcom  firmware patches for VIM devices.  
Refer to the mp1.sh recipe for more info.
- ```opt```  
VIM IP configuration and poweroff patches  
- ```usr```  
vim-specic bluetooth, fan and hdmi scripts
- ```var```  
vim3l asound.state file




<br />
<br />
<br />
<sub> 

## **Platform history**
|Date|Author|Change
|---|---|---|
|2019-11-16|gkkpch|Initial /gkkpch
|2019-11-17|gkkpch|fixed a utf-8 issue with mounting a cifs device
|2019-12-14|gkkpch|add dtb's for Khadas VIM2 & VIM3
|2019-12-16|gkkpch|modified dtb's for audio out, added asound.state for AML_MESONAUDIO/ AML_AUGESOUND
|2020-03-10|gkkpch|rename uboot files to support Krescue setup
|2020-03-20|gkkpch|add main-line uboot and modified UUID registration (add env.txt instead of using boot.ini)
|2020-03-23|gkkpch|bump to Khadas 4.9.203 kernel, incl. usb audio quirks patch/ add squashfs decomp parallelisation
|2020-03-23|gkkpch|OTA updates|gkkpch|fixed boot.ini and env.txt
|2020-03-23|gkkpch|Due to kernel 4.9.206|gkkpch|Soundcard AML-AUGESOUND changed to AML-AUGESOUND-V.
|2020-03-23|gkkpch|Correct partition name variables as a final OTA fix.
|2020-04-01|gkkpch|Updated Khadas u-boot scripts and boot.ini
|2020-04-03|gkkpch|Optimized boot parameter handling, adding boot logo
|2020-04-13|gkkpch|Identical AML-AUGESOUND-V config for VIM3 and VIM3L
|2020-04-14|gkkpch|Optimized cpu frequency scaling with new rc.local script
|2020-04-14|gkkpch|Optimized IRQ cpu affinity
|2020-04-26|gkkpch|Temporary fix for reboot crash/ enabling Khadas remote
|2020-04-27|gkkpch|Updated Auto Installer HOW-TO
|2020-04-27|gkkpch|Temporary disable mcu poweroff for VIM3L/mp1
|2020-07-21|gkkpch|Replaced VIM3L u-boot with the latest from kresc
|2020-07-21|gkkpch|Make Kresc Autoinstaller|gkkpch|obsolete, replaced by Volumio generic
|2020-08-02|gkkpch|Added support for snd-aloop (alsa loop device)
|2020-10-12|gkkpch|Correct installer boot from android uboot environment
|2020-10-13|gkkpch|Correct empty KERNEL_ADDR
|2020-10-15|gkkpch|Boot env|gkkpch|Modification for handling GPIOH_4 (pin37)
|2021-01-09|gkkpch|Change AUGE_SOUND_V sound cardname to AUGE_SOUND_MP1 for VIM3L
|2021-01-24|gkkpch|Follow card.json card naming as AUGE-SOUND-MP1 and AUGE-SOUND-V for VIM
|2021-09-21|gkkpch|Bumped to 4.9.206, experimental eARC support, AUGE sound patch and es90x8q2m driver support













