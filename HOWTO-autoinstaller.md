
### How to create an MP1 Autoinstaller

#### Step 1: Preparation
This step needs to be done only once.  
The prepare script will throw an error at the end.  

	configure: error: Sorry, but we do require libext2fs (part of e2fsprogs).
	make: *** No targets specified and no makefile found.  Stop.

This does no harm, we do not need it.  

    git clone https://github.com/hyphop/khadas-rescue-tools.git
    cd khadas-rescue-tools
    ./scripts/prepare
    
#### Step2: Create the config file
 This step also needs to be done only once.  
 
 Replace the default file **khadas-rescue-tools/projects/VOLUMIO.krescue/make.conf.last** 
 Create one with the following content.  
Make sure **VER** and **DAT** have the values from the image to download.  
 
	LABEL=VOLUMIO
	TPL=krescue.image.conf.tpl
	NAME=MP1.Volumio.last
	VER=2.748
	DAT=2020-04-13
	LINK0=http://updates.volumio.org/mp1/volumio/$VER/
	IMG=volumio-$VER-$DAT-mp1.img.zip
	
	LINK=$LINK0$IMG
	
	#
	SPEEDUP=

#### Step 3: Build the Krescue image
 
This step needs to be done every time a new Krescue Autoinstaller needs to be created.  

Note 1: building an Autoinstaller does not have to be done for every MP1 volumio image version. You can use an older version and do an OTA update.  

Note 2: Replace the logo.bmp in VOLUMIO.krescue/BOOT when a different version is to be used.  

	cd khadas-rescue-tools
	sudo rm -r img
	cd projects/VOLUMIO.krescue
	(do not forget to update the VER and DAT variables in make.conf.last)
	./make

This generates image **/tmp/MP1.Volumio.last.emmc.kresq**

#### Step 4: Generate the MP1 Autoinstaller

	curl -sfL dl.khadas.com/.mega | sh -s - -A VIM3L /tmp/MP1.Volumio.last.emmc.kresq > Autoinstaller-MP1-<version>.img


#### Flash the VIM3L to eMMC
	
Flash the Autoinstaller image to an SD card and boot from it.   
The WHITE led will start blinking for about 15-20 secs while Krescue is reading the VIM3L image file.  
Krescue will blink the RED led while writing to eMMC.   
When the RED led finishes, the WHITE led will continue to blink a few more seconds and then change to STEADY on.   
That is the moment when the autoinstaller has finished.   
Remove the SD and reboot.  

