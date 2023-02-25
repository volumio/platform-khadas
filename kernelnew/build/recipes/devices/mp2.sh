#!/usr/bin/env bash
# shellcheck disable=SC2034

## Setup for Volumio "mp2" device (based on Khadas VIM3L)

## Note: 
# This image uses mainline kernel & u-boot, generated with the
# Khadas Fenix build system
#
# The VIM3L is internally referred to as "mp1". 
# The current Volumio build recipe is therefore referred to as "mp1.sh".  
# However, mp1 with a **mainline** kernel must co-exist with mp1 with version **4.9.206**.
# This will last until the decision is made to switch from the vendor to the mainline kernel.   
# Therefore the mainline image recipe cannot replace "mp1.sh" until then.
# In the meantime, the recipe will be referred to as "mp2.sh". 
# The necessary temporary changes are reflected in DEVICENAME and DEVICEBASE, see below. 
 
DEVICE_SUPPORT_TYPE="O" # First letter (Community Porting|Supported Officially|OEM)
DEVICE_STATUS="T"       # First letter (Planned|Test|Maintenance)

# Base system
BASE="Debian"
ARCH="armhf"
BUILD="armv7"
UINITRD_ARCH="arm64"

### Device information
#DEVICENAME="Volumio MP1"
DEVICENAME="Volumio MP2"
DEVICEFAMILY="khadas"
#DEVICEBASE="mp1"
DEVICEBASE="mp2"
# tarball from DEVICEFAMILY repo to use
DEVICEREPO="https://github.com/volumio/platform-${DEVICEFAMILY}.git"
UBOOTBIN="u-boot.bin.sd.bin"

### What features do we want to target
# TODO: Not fully implement
VOLVARIANT=no # Custom Volumio (Motivo/Primo etc)
MYVOLUMIO=yes
VOLINITUPDATER=yes
KIOSKMODE=yes

## Partition info
BOOT_START=16
BOOT_END=80
BOOT_TYPE=msdos          # msdos or gpt
BOOT_USE_UUID=yes        # Add UUID to fstab
IMAGE_END=3800
INIT_TYPE="init.nextarm" # init.{x86/nextarm/nextarm_tvbox}

# Modules that will be added to intramsfs
MODULES=("overlay" "squashfs" "nls_cp437" "fuse")
# Packages that will be installed
PACKAGES=("lirc" "fbset" "mc" "abootimg" "bluez-firmware"
  "bluetooth" "bluez" "bluez-tools"
)

### Device customisation
# Copy the device specific files (Image/DTS/etc..)
write_device_files() {

  log "Running write_device_files" "ext"

  cp -R "${PLTDIR}/${DEVICEBASE}/boot" "${ROOTFSMNT}"

  log "Copying platform lib defaults"
  cp -pR "${PLTDIR}/${DEVICEBASE}/lib" "${ROOTFSMNT}"

  cp -R "${PLTDIR}/${DEVICEBASE}/lib/modules" "${ROOTFSMNT}/lib"
  cp -R "${PLTDIR}/${DEVICEBASE}/lib/firmware" "${ROOTFSMNT}/lib"

  log "Merge Khadas-specific firmware with the Armbian version"
  cp -r "${PLTDIR}/${DEVICEBASE}"/hwpacks/wlan-firmware/* "${ROOTFSMNT}/lib/firmware"

  log "Add platform regulatory database"
  cp "${PLTDIR}/${DEVICEBASE}"/regulatory.db/* "${ROOTFSMNT}/lib/firmware"

  log "Retain copies of the u-boot binary for Volumio Installer"
  [ -d "${ROOTFSMNT}/u-boot" ] && mkdir "${ROOTFSMNT}/u-boot"
  cp -r "${PLTDIR}/${DEVICEBASE}/u-boot/${UBOOTBIN}" "${ROOTFSMNT}/u-boot"

  log "Adding Wifi & Bluetooth firmware and helpers NOT COMPLETED TBS"
  cp "${PLTDIR}/${DEVICEBASE}/hwpacks/bluez/hciattach-armhf" "${ROOTFSMNT}/usr/local/bin/hciattach"
  cp "${PLTDIR}/${DEVICEBASE}/hwpacks/bluez/brcm_patchram_plus-armhf" "${ROOTFSMNT}/usr/local/bin/brcm_patchram_plus"

  log "Adding services"
  mkdir -p "${ROOTFSMNT}/lib/systemd/system"
  cp "${PLTDIR}/${DEVICEBASE}/lib/systemd/system/bluetooth-khadas.service" "${ROOTFSMNT}/lib/systemd/system"

  log "Adding usr/local/bin & usr/bin files"
  cp -pR "${PLTDIR}/${DEVICEBASE}/usr" "${ROOTFSMNT}"

  log "Copying rc.local with all prepared ${DEVICE} tweaks"
  cp "${PLTDIR}/${DEVICEBASE}/etc/rc.local" "${ROOTFSMNT}/etc"

  log "Copying triggerhappy configuration"
  cp -pR "${PLTDIR}/${DEVICEBASE}/etc/triggerhappy" "${ROOTFSMNT}/etc"

  log "Adding Alsa asound.state"
  cp -pR "${PLTDIR}/${DEVICEBASE}/var/lib/alsa/asound.state" "${ROOTFSMNT}/var/lib/alsa"

}

write_device_bootloader() {

  log "Running write_device_bootloader" "ext"
  dd if="${PLTDIR}/${DEVICEBASE}/u-boot/${UBOOTBIN}" of="${LOOP_DEV}" bs=444 count=1 conv=fsync,notrunc >/dev/null 2>&1
  dd if="${PLTDIR}/${DEVICEBASE}/u-boot/${UBOOTBIN}" of="${LOOP_DEV}" bs=512 skip=1 seek=1 conv=fsync,notrunc >/dev/null 2>&1

}

# Will be called by the image builder for any customisation
device_image_tweaks() {
  :
}

### Chroot tweaks
# Will be run in chroot (before other things)
device_chroot_tweaks() {
  :
}

# Will be run in chroot - Pre initramfs
device_chroot_tweaks_pre() {
  log "Performing device_chroot_tweaks_pre" "ext"

  log "Creating boot parameters from template"
  sed -i "s/#imgpart=UUID=/imgpart=UUID=${UUID_IMG}/g" /boot/env.system.txt
  sed -i "s/#bootpart=UUID=/bootpart=UUID=${UUID_BOOT}/g" /boot/env.system.txt
  sed -i "s/#datapart=UUID=/datapart=UUID=${UUID_DATA}/g" /boot/env.system.txt

  log "Fixing armv8 deprecated instruction emulation, allow dmesg"
  cat <<-EOF >>/etc/sysctl.conf
#Fixing armv8 deprecated instruction emulation with armv7 rootfs
abi.cp15_barrier=2
#Allow dmesg for non.sudo users
kernel.dmesg_restrict=0
EOF

  log "Adding default wifi"
  #echo "dhd" >>"/etc/modules"
}

# Will be run in chroot - Post initramfs
device_chroot_tweaks_post() {
  log "Running device_chroot_tweaks_post" "ext"

  log "Configure triggerhappy"
  echo "DAEMON_OPTS=\"--user root\"" >>"/etc/default/triggerhappy"

  log "Enabling KVIM Bluetooth stack"
  ln -sf /lib/firmware /etc/firmware
  ln -s /lib/systemd/system/bluetooth-khadas.service /etc/systemd/system/multi-user.target.wants/bluetooth-khadas.service

  log "Creating symbolic links for broadcom firmware"
  ln -s /lib/firmware/brcm/brcmfmac4359-sdio.bin /lib/firmware/brcm/brcmfmac4359-sdio.khadas,vim3l.bin
  ln -s /lib/firmware/brcm/brcmfmac4359-sdio.txt /lib/firmware/brcm/brcmfmac4359-sdio.khadas,vim3l.txt

  log "Tweaking default WiFi firmware global configuration"
  echo 'kso_enable=0
ccode=ALL
regrev=38
PM=0
nv_by_chip=5 \
43430 0 nvram_ap6212.txt \
43430 1 nvram_ap6212a.txt \
17221 6 nvram_ap6255.txt  \
17236 2 nvram_ap6356.txt \
17241 9 nvram_ap6359sa.txt' > "${ROOTFSMNT}/lib/firmware/brcm/config.txt"
}

# Will be called by the image builder post the chroot, before finalisation
device_image_tweaks_post() {
  log "Running device_image_tweaks_post" "ext"
  log "Creating uInitrd from 'volumio.initrd'" "info"
  if [[ -f "${ROOTFSMNT}"/boot/volumio.initrd ]]; then
    mkimage -v -A "${UINITRD_ARCH}" -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d "${ROOTFSMNT}"/boot/volumio.initrd "${ROOTFSMNT}"/boot/uInitrd
    #rm "${ROOTFSMNT}"/boot/volumio.initrd
  fi
  if [[ -f "${ROOTFSMNT}"/boot/boot.cmd ]]; then
    log "Creating boot.scr"
    mkimage -A arm -T script -C none -d "${ROOTFSMNT}"/boot/boot.cmd "${ROOTFSMNT}"/boot/boot.scr
  fi
}



