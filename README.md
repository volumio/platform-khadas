# **platform-khadas**
This repo contains all platform-specific files, used by the Volumio buildrecipes for Khadas sbc's

<sub>

|Date|Author|Change
|---|---|---|
|25.02.2023|gkkpch|Merged platform-mp into platform-khadas

<br />
</sub>


# **Contents**
## **Kernel 4.9.206**
Here you find all information regarding the Khadas legacy kernel 4.9.206  
Used for the current (early 2023) range of Volumio products Rivo, Primo 2, Integro.

## **KernelNew**
Here you find all information regarding 
* Khadas mainline kernel 6.x.y for VIM3L
* Khadas vendor kernel 5.4.y fdor VIM1S

## **mp2.tar.xz**
Compressed platform files for VIM3L with mainline kernel

## **vim1s.tar.xz**
Compressed platform files for VIM1S with vendor kernel 5.4.y

## **vims.tar.xz**
Compresses platform files for VIM3L with legacy kernel 4.9.206

## **Developer info for all Khadas boards**

**Serial console**  
```
- pin 17 GND  
- pin 18 RX  
- pin 19 TX
```
Setup VIM3L, baudrate 115200kbps, no hw flowcontrol.
Setup VIM1S, bausrate 921600Kbps, no hw flowcontrol.

Using the serial console is worthwhile with mp1, it is an easy way to make quick changes and tests without having to use ssh.  
Though not absolutely necessary for normal work, it is a **must** when testing kernel and u-boot.

**SPDIF**
```
- Pin 13 SPDIF  
- Pin 14 GND
```
I created a short cable with an RCA socket and used a 100R resistor with the signal line (pin 13) just to keep on the safe side.  
Works perfectly well with spdif-in on my headphone and main amplifiers.





