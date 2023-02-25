## Check list for 
* **VIM3L mainline kernel & u-boot**
* **VIM1S vendor kernel & u-boot**

**Preparation work** 
* [x] Email Igor Pecovnik
* [x] Collect VIM3L
* [x] Setup protection case
* [x] Test VIM3L/ Check boot factory new
* [x] Setup debug environment
* [x] Setup VM Ubuntu Jammy
* [x] Copy DEXQ build/ adapt for mp1
* [x] Create a default Armbian buster image as a reference
* [x] Test default Armbian image
    * [x] Fix mainline boot issue (factory initialised boards won't boot mainline kernel)
    Erase emmc with "store init 3", then boot from SD. Works with the "old" board series. 
    This would also need support from a Volumio core team member on a fresh factory vim3l board ("new" series ref. Andrey).
    * [x] Check Khadas/ Armbian forum for help
    * [x] Test boot issue
    * [x] Extract mainline boot script for reference
  
**03.10.22/ Preparation completed**
**20.10.22/ Preparation reopened for Khadas Fenix use**
* [x] Install khadas-fenix on VM

* [x] Contact Khadas (numbqq)
    * [x] Follow up on Khadas response
    * [x] Fix GPIOH_4
    * [x] Why is Fenix failing since 28.10 --> Fenix 1.2.2 required

**Building volumio-specific kernel and u-boot**
* [x] Develop automated Khadas kernel and u-boot build for mp1ml
* [x] Document build procedure (README.md)
* [x] Setup platform files
* [x] Create default kernel config **linux-meson64-current.config** from the default Ubuntu image
* [x] Test "automated" Khadas kernel/u-boot build for mp1ml
* [x] Compress platform files
* [x] Check u-boot "dd" offsets
* [x] Check legacy kernel patch(es) from the Volumio Team with Mi, are they still relevant with the mainline kernel? 
* [x] Add Volumio patches
    * [x] Enable UART3 (dtb overlay)
    * [?] Support for higher I2S frequencies (384Khz, check legacy patch)


**28.10.22/ Add VIM1S kernel & u-boot**
* [x] Develop automated Khadas kernel and u-boot build for VIM1S
* [x] Document build procedure (README.md)
* [x] VIM1S kernel (5.4)
* [x] VIM1S u-boot
* [x] Add to platform files
* [x] Test build
    * [x] Check Fenix with Khadas (Fenix 1.3 required)
    * [x] Correct build process


**Build recipe for mp1ml mainline kernel image**
* [x] Develop build recipe for mp1 mainline
    * [x] Extract uboot env (use 'printenv' from u-boot cmd line)
        * [x] Compare with Volumio's legacy u-boot env 
        * [x] Compare with Armbian u-boot script   
* [x] Setup mainline boot script
    * [x] Volumio-like u-boot script? 
        * [no] or .. stick to the Armbian script standard?
        * [x] or .. mix the two?
        * [x] Add overlay dtb handling (see Armbian boot script)
        * [ ] Add a new overlay to modify the AML_AUGESOUND cardname (see VIM1S)
    * [x] Watch out for board difference VIM3 and VIM3L (user space may need to know)
    * [fails] Resetting GPIOH_4 to low and echo (gpio 35)
        * [x] GPIOH_4 does not exist, fix for mainline u-boot (unknown gpio)
            * [x] Raise question on Khadas forum
            * [x] Fixed (use "gpio set 20 0")
    * [x] Create boot.scr form boot.ini (boot.ini not working with mainline)
        * [x] Initial boot.scr working?
    * [x] Recreate "multiboot": "usb -> sd -> emmc" sequence 
    * [x] Fix kernel issues resulting from the boot process (nls, alsa, br4cmfmac4359-sdio.khadas.vim3l.txt, more?) 
* [x] Combine mp1.sh/kvims.sh/nanopim4.sh into a new **mp1ml**
* [x] Check Khadas Fenix BSP (firmware changes for mainline, alsa asound.state etc.)
* [x] Add wireless and bluetooth (note VIM3/VIM3L differences)
    * [x] Only copy relevant wifi and bluetooth firmware (see fenix/build-board-deb line 349-362 and kvims.sh)

=== Armbian kernel dropped
* [x] **Switch to Khadas uboot/kernel**
    * [x] small changes mp1ml (use ".deb"-folder "Khadas", use u-boot binary name "uboot.bin.sd.bin")
    * [x] Optimise boot.cmd (minimal)
* [x] Remove ohdmi.service (depricated) and fan.service (not necessary)
* [ ] Add missing services & settings vim3l
* [ ] Add mainline asound.state for vim3l
* [ ] Modify initramfs to check for legacy u-boot in "kernel update block" --> replace by mainline u-boot
* [ ] Debug boot volumio image

**Build recipe for vim1s**
* [x] Make an mps-family from mp1ml.sh and vim1s.sh
* [x] Remove family mps
* [x] Create vim1s.sh 
* [x] Test vim1s boot process
    * [x] See if we can change the extlinux.conf method to boot.ini
    * [x] Adapt boot proces scripts to volumio requirements: create uboot script boot.ini
    * [failed] Test boot.ini
        * [x] boot.ini seems ok, but kernel crashes when reading RAMDISK
        * [x] notify Khadas and ask for support
        * [x] Test ramdisk temporary fix with extlinux.conf
        * [x] Replace boot.ini by extlinux.conf, uEnv.txt, kvim1s.dtb.overlay.env
    * [failed] Boot first image
        * [x] Fix missing dt overlays
        * [x] Fix WLAN issues
        * [x] Fix USB Audio issues
        * [x] Fix ALSA first boot issue "/usr/share/alsa/alsa.conf cannot be accessed"
        * [x] Implement rc.local for VIM1S
    * [x] Implement DT overlays, use a Volumio-specific  one for changing the soundcard name
* [x] Enhance vim1s.sh with vim1s specific settings & services
    * [x] Add bluetooth, firmware etc. 

**Mainline u-boot boot issue with Volumio updater**
* [failed] Boot mainline kernel with legacy u-boot
    * [x] System still bootable from sd when update u-boot on emmc crashed? 
    * [failed] Emergency option vim3l
        * [ ] fix via bootloader special recover image (only works on booted device).
        * [ ] u-boot recovery via specific initrd (simplified installer). This is **THE** only feasible and working option.

**Tweaking mp1/vim1s performance (rc.local)**
* [ ] Set cpufreqs
* [ ] Set smp-affinity
* [x] Activate WOL VIM1S
* [ ] Activate WOL MP1
* [ ] Remove console log
* [ ] Add Plymouth (take fenix settings as sample)

**Autoinstallers and u-boot recovery for mp1ml**
* [ ] Create autoinstaller 
    * [ ] NOTE!!!!: A current 4.9 kernel MP1 device will not be able to "update" to a Kernel 5.0
    This is because it needs a mainline u-boot, we can't change u-boot just with the Volumio updater.
    It will need a full-proof initramfs fix, not sure how to do that yet.
* [ ] Create simple u-boot recovery image for mp1ml

<br />
<br />
<br />
<br />
<sub> 2022.12.29/ Gé

