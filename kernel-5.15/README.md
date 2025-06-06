# **HOW-TO build a kernel & u-boot using Khadas Fenix**
## **Board coverage: VIM1S and VIM4**

### **Prerequisites**

- x86/x64 machine running any OS; at least 4G RAM, SSD.
- VirtualBox or similar virtualization software (highly recommended with a minimum of 50GB hard disk space for the virtual disk image).
- Supported compilation environment is Ubuntu 20.04 LTS (Focal) or later!
- Superuser rights (configured sudo or root access).

### **Recommendation**
Compilation environment support changes from time to time.
A Virtualbox is therefore strongly advised as it gives you more flexibility when your build environment needs to be changed.

### **Notes on kernel and u-boot version**
Fenix 1.7.3 currently supports
- VIM1S/VIM4
    - kernel **5.15.y**
    - u-boot **v2019.01**

Note: please do **not modify** the downloaded Fenix script tree.
These changes will be removed each time the ```custom-kernel.sh``` script (see below) is executed.
In case you do need modifications, save them on the platform folder and re-apply them after the custom script does its initial "git pull".
For an example, see the re-application of the kernel configuration file in ```custom-kernel-vim1s.sh```.

## **Kernel configuration prerequisites for Khadas board**
Though the inital configuration  is based on what khadas delivers, there some configuration parameters to consider, which were modified/added for Volumio.  
This list is not complete, nevertheless consider it as a checklist to ensure the minimum requirements for Volumio are met.  
Specifically for VIM1S: note the configuration parameters which are explicitly **NOT SET**.

**Deprecaterd ARMV8 instruction handling**
- CONFIG_ARMV8_DEPRECATED=y
- CONFIG_SWP_EMULATION=y
- CONFIG_CP15_BARRIER_EMULATION=y
- CONFIG_SETEND_EMULATION=y

**Audio**
- CONFIG_SND_PROC_FS=y
- CONFIG_SND_ALOOP=m
- CONFIG_SND_USB_AUDIO=y

**Various filesystems**

- CONFIG_EXT2_FS=y
- CONFIG_EXT3_FS=y
- CONFIG_EXT3_FS_POSIX_ACL=y  
recommended
- CONFIG_EXT3_FS_SECURITY=y  
recommended 
- CONFIG_EXT4_FS=y
- CONFIG_EXT4_USE_FOR_EXT2=y
- CONFIG_EXT4_FS_POSIX_ACL=y
- CONFIG_EXT4_FS_SECURITY=y

- CONFIG_EXFAT_FS=m
- CONFIG_EXFAT_DEFAULT_IOCHARSET="utf8"
- CONFIG_AUTOFS4_FS=y



**OverlayFS filesystem**
- CONFIG_OVERLAY_FS=m
- \# **CONFIG_OVERLAY_FS_REDIRECT_DIR is not set**
- CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW=y
- \# **CONFIG_OVERLAY_FS_INDEX is not set**
- \# **CONFIG_OVERLAY_FS_XINO_AUTO is not set**
- \# **CONFIG_OVERLAY_FS_METACOPY is not set**



**SquashFS filesystem**
- CONFIG_SQUASHFS=m    
'm' is minimum, as it will be "modprob-ed" in initrd"
- CONFIG_SQUASHFS_FILE_CACHE=y
- \# **CONFIG_SQUASHFS_FILE_DIRECT is not set**
- CONFIG_SQUASHFS_DECOMP_SINGLE=y
- \# **CONFIG_SQUASHFS_DECOMP_MULTI is not set**
- \# **CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU is not set**
- \# **CONFIG_SQUASHFS_XATTR is not set**
- CONFIG_SQUASHFS_ZLIB=y
- CONFIG_SQUASHFS_LZ4=y
- CONFIG_SQUASHFS_LZO=y
- CONFIG_SQUASHFS_XZ=y
- CONFIG_SQUASHFS_ZSTD=y
- \# **CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set**
- \# **CONFIG_SQUASHFS_EMBEDDED is not set**

**DOS/FAT/NT Filesystems**

- CONFIG_FAT_FS=y
- CONFIG_MSDOS_FS=y
- CONFIG_VFAT_FS=y
- CONFIG_FAT_DEFAULT_CODEPAGE=437
- CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
- \# CONFIG_FAT_DEFAULT_UTF8 is not set
- \# CONFIG_NTFS_FS is not set
- CONFIG_NTFS3_FS=y

**Pseudo filesystems**
- CONFIG_PROC_FS=y




## **How to build the Khadas kernel and u-boot for Volumio?**

Install the essentials
```
$ sudo apt-get update
$ sudo apt-get install git
```

Prepare the build environment with 2 separate fenix script folders

```
$ cd $HOME
$ git clone https://${GH_TOKEN}github.com/volumio/platform-khadas
$ cd platform-khadas/kernel-5.15/lib
$ chmod +x *.sh
$ cd $HOME
$ git clone http://github.com/khadas/fenix fenix-vim1s --depth 1       # VIM1S
$ git clone http://github.com/khadas/fenix fenix-vim4 --depth 1        # VIM4
```
In case you decide not to clone them to your $HOME folder, then do not forget to
modify the paths in the ```vim1s.conf``` and ```vim4.conf``` files.
You will find these in ```platform-khadas/kernel-5.15/lib```. Best to quickly review these anyway.

## **Compile u-boot**

Use this when you initially build kernel and u-boot or when taking Fenix updates into account:
### VIM1S

```
$ cd <your platform-khadas/kernel-5.15/lib>
$ ./make-uboot-vim1s.sh
```
### VIM4
```
$ cd <your platform-khadas/kernel-5.15/lib>
$ ./make-uboot-vim4.sh
```

After succesfull compilation, the u-boot .deb package is transferred automatically to the correct khadas/debs subfolder in the platform repo. It will be used by the Volumio build recipies.

## **Compile the kernel** ##

For VIM1S 
```
$ cd <your platform-khadas/kernel-5.15/lib>
$ ./custom-kernel-vim1s.sh
```
For VIM4, it uses same kernel as VIM1S. Following script only updates device tree overlay deb for VIM4. Use the above script to update the kernel instead.
```
$ cd <your platform-khadas/kernel-5.15/lib>
$ ./custom-kernel-vim4.sh
```
The script has 5 stages
- Preparation 
- Kernel configuration (you can leave with <exit> when there is nothing to do)
- Kernel compilation
- Backing up the kernel configuration to the correct khadas/configs subfolder in the platform repo. It will be picked from there with for the next kernel compile.
- Copying the kernel .deb packages to the correct khadas/debs subfolder in the platform repo. These will be used by the Volumio build recipies.

## **Build the platform files** ##

This step needs to be done to transfer the necessary information from the previously generated .deb files in to the platform-khadas/vims-5.15 folder used by the Volumio 3 build recipe.

For VIM1S
```
$ cd <your platform-khadas/kernel-5.15/lib>
$ ./build-platform-vim1s.sh
$ cd ..
$ tar cfJ vim-5.15.tar.xz ./vim-5.15
$ git add vim-5.15.tar.xz
$ git commit -m "{your comment}"
$ git push
```

For VIM4 it is similar
```
$ cd <your platform-khadas/kernel-5.15/lib>
$ ./build-platform-vim4.sh
$ cd ..
$ tar cfJ vims-5.15.tar.xz ./vims-5.15
$ git add vim-5.15.tar.xz
$ git commit -m "{your comment}"
$ git push
```

<br />

## Changelog

<sub> 

|Date|Author|Change
|---|---|---|
|||gkkpch/ Gé koerkamp/ ge.koerkamp@gmail.com
|29.12.2022|gkkpch|v1.1 Completed vim1s platform build
|30.12.2022|gkkpch|v1.2 Completed mp1 platform build
|25.01.2023|gkkpch|v1.3 Optimized some scripts and documentation
|26.01.2023|gkkpch|v1.4 Updated documentation
|30.01.2023|gkkpch|Cleaned up, correct the XATTR/ squashfs issue (lost on 26.01)
|10.02.2023|gkkpch|Patched WiFi: 
|||meson-g12-common.dtsi, node sd_emmc_a: "interrupts = <GIC_SPI 189 IRQ_TYPE_LEVEL_HIGH>"
|||rc.local for restarting brcmfmac (workaround)
|||bootscript/ env modifications
|||reguratory db (wireless)
|24.02.2023|gkkpch|Kernel: mmc: meson-gx: fix SDIO mode if cap_sdio_irq isn't set
|||Kernel: arm64: dts: meson-gx: Make mmc host controller interrupts level-sensitive
|||mp2 build: does not need rc.local brcmfmac bypass now with the SDIO fixes
|12.03.2023|gkkpch|vim1s build: fixed ```/boot/extlinux/extlinux.conf``` issue with missing partitiontype "generic"
|||vim1s build: cleaned out unused files
|07.04.2025||Added vim1s and vim4 support based on 5.15 vendor kernel


