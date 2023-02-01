# platform-khadas
Contains all the khadas-specific kernel and build files

kernel: http://github.com/khadas/linux
branch: khadas-vims-4.9.206

uboot: https://github.com/hyphop/khadas-uboot-spi/releases/tag/vims
alternative: http://github.com/khadas/u-boot

hwpacks and other: http://github.com/khadas/fenix

patches: see usb-audio patch in this repo
kernel build: see script in this repo plus kernel config in vims.tar.xz

<sub>

|Date|Author|Change
|---|---|---|
|2019-11-16|gkkpch|Initial /gkkpch
|2019-11-17|gkkpch|fixed a utf-8 issue with mounting a cifs device
|2019-12-14|gkkpch|add dtb's for Khadas VIM2 & VIM3
|2019-12-16|gkkpch|modified dtb's for audio out, added asound.state for AML_MESONAUDIO/ AML_AUGESOUND
|2020-03-10|gkkpch|rename uboot files to support Krescue setup
|2020-03-20|gkkpch|add main-line uboot and modified UUID registration (add env.txt insteadof using boot.ini)
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
|2021-09-21|gkkpch|Bumpt to 4.9.206, experimental eARC support, AUGE sound patch and es90x8q2m driver support
|2023-02-01|gkkpch|Modified boot.ini: VIM3L board revision now irrelevant
|||Removed boot support for VIM1/ VIM2/ VIM3













