# **PiZero-ZoneMinder-Cam**
### A Low cost ZoneMinder network IP camera using a Raspberry Pi Zero and a Pi camera

****

## Index
* [1 - What is the PiZero-ZoneMinder-Cam?](#whatis)
* [2 - Q&A before you start](#qa)
* [3 - Cost breakdown](#cost)
* [4 - Requirements](#requirements)
* [5 - Installation](#installation)
  * [5.1 - Micro SD preparation](#installation-prepare)
  * [5.2 - First boot](#installation-firstboot)
  * [5.3 - Assigning a static IP](#installation-staticip) *(optional)*
  * [5.4 - Disable Raspberry Pi Zero W onboard WiFi](#installation-disablewifi)
  * [5.5 - Permanently disable SWAP to extend your SD card life](#installation-disableswap) *(optional)*
  * [5.6 - Install phpSysInfo](#installation-physysinfo) *(optional)*
  * [5.7 - Install SSDP Responder](#installation-ssdpresponder) *(optional)*
  * [5.8 - Install PiZero-ZoneMinder-Cam](#installation-main)
  * [5.9 - Move folders from the SD card to RAM using TMPFS](#installation-tmpfs) *(optional)*
* [6 - Configuration](#config)
  * [6.1 - PiZero-ZoneMinder-Cam configuration](#config-cam)
  * [6.2 - ZoneMinder configuration](#config-zm)
* [7 - Donate](#donate)

****

## **1 - What is the PiZero-ZoneMinder-Cam?** <a name="whatis"></a>
It is a very **low cost** camera built from a Raspberry Pi Zero, a Raspberry Pi camera and a cheap USB-WiFi module.

This setup is meant to be connected to a **ZoneMinder** server on your network, where you can add and configure your cameras (recording, movement detection, etc) as you please.

Here are the specifications I have for the PiZero-ZoneMinder-Cam that I am currently running:
* Encoding format: **MJPEG** *(the best format for high quality frames and advised by ZoneMidner for having many cameras in one system)*
* Resolution: **1920x1440** at 4:3 on the sensor full FOV *(1920x1080 works fine but it does not capture the full FOV and the native 2592x1944 did not work with ZoneMinder)*
* Frames per second: **2** *(you can add more, but for this purpose I dont think there is any sense to add more)*
* Bitrate: **5 Mbps** *(you can change this up to about 15-17 Mbits, but you need to balance between your network bandwidth, number of cameras and bitrate per frame - MJPEG uses individual frames, so less framerate means more quality for the same bitrate)* 

I abandoned some ready to use software/builds available online because of how heavy they were. I also avoided cheap IP cameras because **I do not want any of my private home cameras connected to a cloud** somewhere on the world.

****

## **2 - Q&A before you start** <a name="qa"></a>
### Why are you not using MotionEye or MotionEyeOS?
I actually have tried these options, but I abandoned them because:
* They were quite heavy and extremelly slow on a Raspberry Pi Zero, as most part of the tasks were CPU intensive.
* They included features like motion detection, text overlay, video recording, which I was not planning to run on-camera and were quite heavy for my Raspberry Pi Zero
* Provided dissapointing H264 encoding results (over WiFi) with lots of artifacts rendering the footage somehow unsusable for motion detection
* Provided MJPEG encoding option with a very basic setup and didn't offer a lot of configuration options
* The encoding was done via software, not taking advantage of the hardware for MJPEG and H.264

### Why are you not using a cheap IP camera from eBay/Amazon/DealExtreme/Gearbest?
Although you can get quite cheap IP cameras there, this is quite simple to answer:
* I really do not want to add cameras to my private home that may stream to a cloud somewhere out of my home
* I want to avoid situations where you order 10 similar cameras, and when they arrive half of them come with a completely different firmware
* These cheap cameras have very little *(if any)* documentation available
* I really prefer to have full control over the equipment I own, which is not possible with a cheap IP plug-and-play camera

### Why are you using a non-WiFi Raspberry Pi Zero (non-W model)?
Apart from choosing the cheapest option *(non WiFi model)*, the Raspberry Pi Zero W *(with embedded WiFi module)* has quite a lot of bugs that havent been solved since few years, here are the ones I dealt with when using the onboard WiFi:
* [wlan freezes in raspberry pi 3/PiZeroW (Not 3B+)](https://github.com/raspberrypi/linux/issues/1342)
* [Kernel oops or hard freeze when streaming video on Zero W (and Pi 3B+)](https://github.com/raspberrypi/linux/issues/2555)

From my personal tests, the Raspberry Pi Zero W always crashes the network interface few minutes after streaming video over WiFi, which was only resolved via a full reboot, happening again few minutes later after the stream restarted.
I decided that this solution *(with onboard WiFi)* was very unreliable for a device that is supposed to stay online 24/7/365 without human contact.
I then tested one of those cheap USB-WiFi dongles available on eBay or related websites, which worked perfectly without any package drop *(tested with a constant 5Mbps MJPEG stream)*

### Why are you streaming MJPEG instead of H.264?
There are several advantages and disadvantages on both streams, this table compares the most important points:

|  | MJPEG | H.264 | 
| --- | --- | --- |
| Compression type | Individual frames *(individual JPEGs)* | Across frames *(current frame depends on previous frames)* |
| Network bandwidth used | High | Low |
| Still frame quality | High | Low *(quality decreases the further you are from the key frame)* |
| Adequate for ... frame rates | Low | High |
| Storing space requirements | High | Low |
| Recover from dropped frames | Instant recover *(frames are independent)* | Next frames impacted until key frame apears |
| Support to export video stills | Native *(individual JPEGs)* | Needs key frame and motion vector frames |
| Supported resolution on OV5647 | Up to native *(2592x1944)* | Limited to 1920x1080 *(not confimed)*|
| ZM decoding needed? | No | Yes *(stream is converted to individual JPEGs)* |
| ZM number of cameras | High | Low *(due to CPU usage for the above)* |

Here are some schematics trying to show the main differences between MJPEG and H.264.
This one shows the quality and bandwith needed for each encoding method:

![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/codecs1.png "MJPEG vs H.264")

This one shows what happens in case of a dropped frame. On a MJPEG stream, the stream simply pauses and waits for the next frame, on an H.264 frame the lack of the key frame will corrupt the next frames untill a new key frame is sent:

![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/codecs2.png "MJPEG vs H.264")

For this project **I decided to go with MJPEG** because I am more interested in having **sharp image quality** per frame rather than bandwidth efficiency. Also in case some frames are dropped I prefer to have the instant recovery that MJPEG offers rather than the few seconds of corrupted images from the H.264 when operating at a low framerate. I will be using a low framerate (about 2-5 fps) and ZoneMinder will take care of encoding into H.264 in order to store the footage. ALso according to ZM website unless you have a powerful server stick with MJPEG cameras.
For my setup the bandwidth is not really an issue as I will have separate networks for surveilance + IOT and for general use (laptop, TV, phones, etc) so MJPEG was the choice.

****

## **3 - Cost breakdown** <a name="cost"></a>
*NOTE: As I live in Poland, I bought some elements directly from Polish websites, so the prices will appear in PLN. Buying the Raspberry Pi Zero and the Micro SD card were cheaper to buy in Poland rather than eBay, so I didn't include eBay prices for them.*
The prices are listed as of 19th April 2019

### **Price for each option**
Board+Card | Cost
--- | ---
Raspberry Pi Zero (PL) | **26.00 zł** (~$6.83)
Kingston 16GB C10 U1 (PL) | **11.87 zł** (~$3.12)

WiFi | Cost
--- | ---
WiFi 150Mbps module (PL) | **9.92 zł** (~$2.32)
WiFi 150Mbps module (eBay) | $1.39 **(~5.29 zł)**
Adapter microUSB-OTG (PL) | **3.49 zł** (~$0.82)
Adapter microUSB-OTG (eBay) | $0.33 **(~1.26 zł)**

Camera | Day vision | Night vision | Day+Night vision
--- | --- | --- | ---
OV5647 regular camera (PL) | **44.90 zł** (~$11.79)  | **72.90 zł** (~$19.15) | **105.00 zł** (~$27.58)
OV5647 wide camera (PL) | **52.90 zł** (~$13.89) | **72.90 zł** (~$19.15) | -
OV5647 regular camera (eBay) | $9.63 **(~36.67 zł)** | $14.88 **(~56.66 zł)** | $17.81 **(~67.81 zł)**
OV5647 wide camera (eBay) | $12.74 **(~48.51 zł)** | $14.42 **(~54.90 zł)** | $19.99 **(~76.11 zł)**

### **Totals**
#### Polish stores only
Option | Delivery | Cost (zł) | Cost ($)
--- | --- | --- | ---
Regular day vision | Fast | 96.18 zł | $24.88
Wide day vision | Fast | 104.18 zł | $26.98
Regular night vision | Fast | 124.18 zł | $32.24
Wide night vision | Fast | 124.18 zł | $32.24
Regular day+night vision | Fast | 156 zł | $40.67
Wide day+night vision | Fast | - | -

#### eBay only *(except Rpi Zero + SD card)
Option | Delivery | Cost (zł) | Cost ($)
--- | --- | --- | ---
Regular day vision | Slow | 77.49 zł | $20.16
Wide day vision | Slow | 89.33 zł | $23.27
Regular night vision | Slow | 97.48 zł | $25.41
Wide night vision | Slow | 95.72 zł | $24.95
Regular day+night vision | Slow | 108.63 zł | $28.34
Wide day+night vision | Slow | 116.93 zł | $30.52

### **Where to buy?**
Item | Store | Link
--- | --- | ---
Raspberry Pi Zero | Botland (PL) | [Link](https://botland.com.pl/en/modules-and-kits-raspberry-pi-zero/5215-raspberry-pi-zero-v13-512mb-ram.html)
Kingston 16GB C10 U1 | Allegro (PL) | [Link](https://allegro.pl/oferta/kingston-karta-microsd-16gb-micro-adapter-sd-7849829127)
OV5647 cameras | Botland (PL) | [Link](https://botland.com.pl/en/945-cameras-for-raspberry-pi)
OV5647 cameras | eBay | [Link](https://www.ebay.com/)

****

## **4 - Requirements** <a name="requirements"></a>

![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/image_elements.PNG "What you will need")

For this setup you will need:
1. Raspberry Pi Zero *(or Zero W, but we won't be using the onboard WiFi)*
2. Micro SD card *(4GB is enough)*
2. USB WiFi stick/module *(see "Why am I using a non-WiFi Raspberry Pi Zero?"" above)*
3. Raspberry Pi Camera *(those common OV5647 based)*
4. USB power supply
6. Keyboard and screen *(with HDMI cable and mini-HDMI adapter)*
7. USB hub *(to plug the keyboard and the WiFi stick/module)*
4. Micro USB OTG adapter *(for the USB hub and later for the WiFi stick/module)*

****

## **5 - Installation** <a name="installation"></a>
Follow these instructions to install the system on your Raspberry Pi Zero:
### 5.1 - Micro SD preparation <a name="installation-prepare"></a>
![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/sdcards.png "SD cards")

Let's start by preparing the micro SD card with the latest Raspbian Lite image:
1. Download the latest **Raspbian Stretch Lite** *(no desktop)* from [the official site](https://www.raspberrypi.org/downloads/)
2. Extract the ZIP file somewhere on your computer
3. Use a tool like **Win32 Disk Imager** ([download here](https://sourceforge.net/projects/win32diskimager/)) or similar to burn the ISO image into your micro SD

### 5.2 - First boot <a name="installation-firstboot"></a>
![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/raspiconfig.png "Raspberry pi configuration")

Let's configure the basics with these steps:
1. Put the micro SD on your Raspberry Pi Zero, plug also the USB hub, keyboard and screen
2. Skip this step if you are using a Raspberry Pi Zero W: Add your WiFi USB dongle *(if you are using the Raspberry Pi Zero **without** WiFi)*, 
3. Power up the device and login using the default user `pi` and password `raspberry`
4. Follow the usual starting procedure via `sudo raspi-config` *(usually you are brought here during first boot)*:
* Change the default password for the user `pi`
* Change the hostname to something like `pi-camera-01`
* Connect to your WiFi network using the SSID and passphase
* Change the Locale, Timezone, Keyboard layout and WiFi country if needed
* Enable the Camera and the SSH under "Interfacing options", so later you can connect remotely to the device from your PC
5. Update the system by typing the following:
* `sudo apt-get update`
* `sudo apt-get upgrade -y`
* `sudo rpi-update`
6. Disable the WiFi power management by doing the following:
* `sudo crontab -e` *(use nano as editor if asked)*
* Add `@reboot /sbin/iwconfig wlan0 power off` to the end of the file
* Save the file by pressing CTRL+O and then exit by pressing CTRL+X
7. Reboot your Raspberry Pi Zero to apply changes by typing `sudo reboot`
8. You should now be able to connect remotely via SSH to your Raspberry Pi Zero using a computer and an SSH terminal like **PuTTY** (get it [here](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)) *(**NOTE:** Use the IP you see on the Raspberry Pi Zero connected screen or just the hostname you have set above)*

### 5.3 - Assigning a static IP *(optional)* <a name="installation-staticip"></a>
![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/static_ip.png "Using static IP")

If you want to assign a static IP instead of using your network DHCP server, follow the next steps *(tested on Rasbian Stretch Lite)*:
1. Type `sudo nano /etc/dhcpcd.conf`
2. Navigate on the file and make sure the following is set *(use your own IP and gateway address)*:
```
# Example static IP configuration:
interface wlan0
static ip_address=192.168.0.30/24
static routers=192.168.0.1
static domain_name_servers=192.168.0.1 8.8.8.8
```
3. Save the file by pressing CTRL+O and then exit by pressing CTRL+X
4. Reboot your Raspberry Pi Zero by typing `sudo reboot`

### 5.4 - Disable Raspberry Pi Zero W onboard WiFi <a name="installation-disablewifi"></a>
![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/pizerow_nowifi.png "Disabling WiFi on Rpi Zero W")

**For Raspberry Pi Zero W only:**
Due to the issues above *(see FAQ section)*, you will **need to disable** the onboard WiFi module and use the USB WiFi dongle instead, to do this follow these steps:
1. Open the boot configuration file by typing `sudo nano /boot/config.txt`
2. Add the following lines to the end of the file:
```
# Disable BT and WiFi:
dtoverlay=pi3-disable-bt
dtoverlay=pi3-disable-wifi
```
3. Save the file by pressing CTRL+O and then exit by pressing CTRL+X
4. Shutdown your Raspberry Pi Zero W by typing `sudo shutdown -h now`, plug in your USB WiFi dongle and power up your Pi Zero W again.
5. After rebooting type `sudo ifconfig` and you should have one interface called `wlan0` with the IP you have assigned/been assigned *(which now is the USB WiFi module and not the onboard WiFi)*, you should also be automatically connected to your WiFi network as well.

### 5.5 - Permanently disable SWAP to extend your SD card life *(optional)* <a name="installation-disableswap"></a>
![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/noswap.png "Disabling SWAP")

In order to extend your SD card life, you may disable the SWAP so it wont use your card as an extension of RAM, follow these steps to disable the SWAP:
1. `sudo swapoff`
2. `sudo dphys-swapfile swapoff`
3. `sudo dphys-swapfile uninstall`
4. `sudo systemctl disable dphys-swapfile`
5. Reboot your Raspberry Pi Zero by typing `sudo reboot`
6. After the reboot, you can confirm if the SWAP was disabled by typing `free -h`. The SWAP should now have 0B/0B/0B

### 5.6 - Install phpSysInfo *(optional)* <a name="installation-physysinfo"></a>
![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/phpsysinfo.png "The phpSysInfo webpage")

To install the phpSysInfo you will need to install Apache webserver and the PHP dependencies, follow these steps to install Apache, PHP and phpSysInfo:
Remember to run `sudo apt-get update` and `sudo apt-get upgrade -y` if you did not run them yet.
**Apache:**
1. `sudo apt-get install apache2 -y`
2. `sudo a2enmod rewrite`
3. `sudo service apache2 restart`
4. You should be able to open a browser on your PC and navigate to the IP/hostname *(example: http://192.168.0.30/)* and you will see an Apache welcome page
5. Now delete this page as we do not need it by typing `sudo rm -rf /var/www/html/*` *(**NOTE:** This will delete all contents of the html folder, make sure you do not have any important files there you may have added in the past)*

**PHP for Apache:**
1. `sudo apt-get install php libapache2-mod-php -y`
2. `sudo service apache2 restart`
3. Note from the command results where the file `php.ini` is located as you will need the location after.

**phpSysInfo:**
1. Make sure you have GIT installed by typing `sudo apt-get install git`
2. Get the latest version from the official page [here](https://github.com/phpsysinfo/phpsysinfo/releases) or directly [here (v3.3.0)](https://github.com/phpsysinfo/phpsysinfo/archive/v3.3.0.zip)
3. Type `git clone https://github.com/phpsysinfo/phpsysinfo/archive/v3.3.0.zip` on your home directory
4. Move all the extracted contents to the webserver folder by typing `sudo cp -r phpsysinfo-3.3.0/* /var/www/html/`
5. Prepare the configuration file by typing `sudo cp /var/www/html/phpsysinfo.ini.new /var/www/html/phpsysinfo.ini.new`
6. Edit the configuration file by typing `sudo nano /var/www/html/phpsysinfo.ini`
7. Copy the contents from the already prepared file `phpsysinfo.ini` provided on **PiZero-ZoneMinder-Cam** under `files/phpsysinfo/` folder
8. Save the file by pressing CTRL+O and then exit by pressing CTRL+X
9. Open the php.ini file from the link you got from the previous step by typing `sudo nano <...>/php.ini`
10. Find the line `include_path` and set it only to `"."`
11. Find *(or create)* a line called `safe_mode` and set it to `safe_mode=off`. This is the most important step as phpSysInfo won't work without this properly set.
11. Save the file by pressing CTRL+O and then exit by pressing CTRL+X
12. You should be able to open a browser on your PC and navigate to the IP/hostname *(example: http://192.168.0.30/)* and you will see the phpSysInfo page with all details about your Raspberry Pi Zero
13. You may now delete the folder `phpsysinfo-3.3.0` you downloaded with git with `rm -rf /home/pi/phpsysinfo*`

### 5.7 - Install SSDP Responder *(optional)* <a name="installation-ssdpresponder"></a>
![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/image_ssdp_camera.png "The device with SSDP responder service")

If you want your Raspberry Pi Zero to show up as a camera device on your Windows Network, then follow these steps:
1. Make sure you have GIT and WGET installed by typing `sudo apt-get install git wget`
2. Get the latest version from the official page [here](https://github.com/troglobit/ssdp-responder/releases) or directly  [here (v1.5)](https://github.com/troglobit/ssdp-responder/releases/download/v1.5/ssdp-responder-1.5.tar.gz)
3. Download the version by typing `wget https://github.com/troglobit/ssdp-responder/releases/download/v1.5/ssdp-responder-1.5.tar.gz`
4. Untar the compressed file by typing `tar -zxvf ssdp-responder-1.5.tar.gz`
5. Go inside the directory with `cd ssdp-responder-1.5`
6. Edit the `web.c` file by typing `nano web.c`
7. Copy the contents from the already prepared file `web.c` provided on **PiZero-ZoneMinder-Cam** under `files/ssdp-responder/` folder
8. Save the file by pressing CTRL+O and then exit by pressing CTRL+X
6. Configure the source code with `./configure`
7. Build the application with `make`, this should take 1~2 minutes
8. Type `sudo make install` to install the SSDP responder application
9. You may delete the file `ssdp-responder-1.5.tar.gz` and folder `ssdp-responder-1.5` with `rm -rf /home/pi/ssdp-responder*`
10. You can test the aplication by typing `sudo ssdpd` and checking on your Windows Network if you have a device with the same name you gave to your Raspberry Pi Zero *(for example pi-camera-01)*
11. To configure the SSDP responder to autostart on every boot do the following:
* `sudo touch /etc/systemd/system/ssdpd.service`
* `sudo nano /etc/systemd/system/ssdpd.service`
* Add the following contents to the file:
```
[Unit]
Description=SSDP responder daemon
After=network-online.target

[Service]
Type=simple
ExecStartPre=/bin/sleep 60
ExecStart=/usr/local/sbin/ssdpd
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```
* Save the file by pressing CTRL+O and then exit by pressing CTRL+X
* `sudo systemctl daemon-reload`
* `sudo systemctl enable ssdpd`
12. Reboot your Raspberry Pi Zero by typing `sudo reboot`
13. After the reboot, verify if the SSDP responder is running by typing `ps aux | grep ssdpd` and you should see the task(s) running
14. You can now browse your network on your Windows PC and you will find the camera as a device, double click on it to open the main webpage *(which will point to phpSysInfo if you have installed it)*

### 5.8 - Install PiZero-ZoneMinder-Cam <a name="installation-main"></a>
![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/pi_camera.png "PiZero-ZoneMinder-Cam")

1. Make sure you have GIT installed by typing `sudo apt-get install git`
2. Get the latest PiZero-ZoneMinder-Cam version from the official page [here](https://github.com/vascojdb/pizero-zoneminder-cam)
3. Type `git clone https://github.com/vascojdb/pizero-zoneminder-cam.git` on your home directory
4. Change to the correct directory with `cd pizero-zoneminder-cam/files/camera-server/`
5. Type `sudo chmod +x install.sh` and then `sudo ./install.sh` to install all the needed files
7. You can edit your settings by typing `sudo nano /etc/pizero-zm-cam.conf` and then saving the file by pressing CTRL+O and then exit by pressing CTRL+X
8. After every change on the configuration, restart the service by typing `sudo systemctl restart pizero-zm-cam`

### 5.9 - Move folders from the SD card to RAM using TMPFS *(optional)* <a name="installation-tmpfs"></a>
![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/oldsd.png "Extend SD life")

If you want to extend your micro SD card life even further you should move most part of the active folders *(logs, tmp, etc)* to the Raspberry Pi Zero RAM using **tmpfs**. To do this follow these steps:
1. Edit the fstab file with `sudo nano /etc/fstab`
2. Add the following entries to the end of the file:
```
tmpfs    /tmp    tmpfs    defaults,noatime,nosuid,size=100m    0 0
tmpfs    /var/tmp    tmpfs    defaults,noatime,nosuid,size=30m    0 0
tmpfs    /var/log    tmpfs    defaults,noatime,nosuid,mode=0755,size=100m    0 0
tmpfs    /var/spool/mqueue    tmpfs    defaults,noatime,nosuid,mode=0700,gid=12,size=30m    0 0
```
3. Save the file by pressing CTRL+O and then exit by pressing CTRL+X
4. Reboot your Raspberry Pi Zero by typing `sudo reboot`

****

## **6 - Configuration** <a name="config"></a>
Follow these steps to configure the PiZero-ZoneMinder-Cam service and ZoneMinder to receive the video stream:
### 6.1 - PiZero-ZoneMinder-Cam configuration <a name="config-cam"></a>
![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/sdcards.png "SD cards")

You can edit your PiZero-ZoneMinder-Cam settings by typing on your Raspberry Pi Zero the command `sudo nano /etc/pizero-zm-cam.conf` and then saving the file by pressing CTRL+O and then exit by pressing CTRL+X

Here is the default configuration found on *pizero-zm-cam.conf*:
```bash
# +------------------------------+
# |  VIDEO SETTINGS (MANDATORY)  |
# +------------------------------+
# Set video width (pixels)
WIDTH=1920
# Set video height (pixels)
HEIGHT=1440
# Set video bitrate. Use bits per second (e.g. 10MBits/s would be -b 10000000)
BITRATE=5000000
# Specify the frames per second to record
FRAMERATE=2
# TCP port to connect
TCP_PORT=5000
# Video format to use (MJPEG or H264)
FORMAT="MJPEG"
# [Available only when format is H264] Set the intra frame refresh period (number of frames between H.264 key frames)
#H264_INTRA=10
# [Available only when format is H264] Set the quantisation parameter (10 to 40), higher values reduce quality and file size
#H264_QUANT_PARAM=20
# [Available only when format is H264] Set the H.264 profile to use (baseline, main, high)
#H264_PROFILE="baseline"
# [Available only when format is H264] Set the H.264 encoder level to use for encoding (4, 4.1 or 4.2)
#H264_LEVEL="4"

# +-----------------------------------+
# |     IMAGE SETTINGS (OPTIONAL)     |
# | Comment with '#' to disable usage |
# +-----------------------------------+
# Set image sharpness (-100 to 100)
#SHARPNESS=0
# Set image contrast (-100 to 100)
#CONTRAST=0
# Set image brightness (0 to 100)
#BRIGHTNESS=50
# Set image saturation (-100 to 100)
#SATURATION=0
# Set capture ISO (100 to 800)
#ISO=100
# Set EV compensation - steps of 1/6 stop (-10 to 10)
#EV=0
# Set exposure mode (off,auto,night,nightpreview,backlight,spotlight,sports,snow,beach,verylong,fixedfps,antishake,fireworks)
EXPOSURE="fixedfps"
# Set flicker avoid mode (off,auto,50hz,60hz)
FLICKER_AVOID="50hz"
# Set AWB mode (off,auto,sun,cloud,shade,tungsten,fluorescent,incandescent,flash,horizon)
AWB="auto"
# Set image effect (none,negative,solarise,sketch,denoise,emboss,oilpaint,hatch,gpen,pastel,watercolour,film,blur,saturation,colourswap,washedout,posterise,colourpoint,colourbalance,cartoon)
#IMAGE_EFFECT="none"
# Set metering mode (average,spot,backlit,matrix)
#METERING="average"
# Set image rotation (0, 90, 180, 270)
#ROTATION=0
# Set horizontal flip
HORIZONTAL_FLIP=true
# Set vertical flip
VERTICAL_FLIP=true
# Set Dynamic Range Compression (DRC) level (off,low,med,high)
DRC="high"
# Enable/Set annotate flags or text (see https://www.raspberrypi.org/documentation/raspbian/applications/camera.md)
#ANNOTATE=12
```

### 6.2 - ZoneMinder configuration <a name="config-zm"></a>
![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/raspiconfig.png "Raspberry pi configuration")

**TODO**

****

## **7 - Donate** <a name="donate"></a>
If you like this project, help me make it even better by donating!
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.me/vascojdb)
