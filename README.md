# **PiZero-ZoneMinder-Cam**
### A very low-cost ZoneMinder network IP camera using a Raspberry Pi Zero, MotionEyeOS and a Pi camera

****

## Index
* [1 - What is the PiZero-ZoneMinder-Cam?](#whatis)
* [2 - Q&A before you start](#qa)
* [3 - Cost breakdown](#cost)
* [4 - Requirements](#requirements)
* [5 - Installation](#installation)
* [6 - MotionEyeOS configuration](#motioneyeos)
* [7 - ZoneMinder configuration](#zm)
* [8 - Building the camera enclosure](#enclosure)
* [9 - Donate](#donate)

****

## **1 - What is the PiZero-ZoneMinder-Cam?** <a name="whatis"></a>
It is a **very low-cost** camera built from a **Raspberry Pi Zero** running **MotionEyeOS** and a Raspberry Pi camera.

This setup is meant to be connected to a **ZoneMinder** server on your network, where you can add and configure your cameras (as well as recording, perform movement detection, etc).

Here are the specifications I have for my cameras:
* Encoding format: **MJPEG** *(the best format for high quality frames and advised by ZoneMidner for having many cameras in one system)*
* Resolution: **2592x1944** native at 4:3 on the sensor full FOV *(1920x1080 works fine but it does not capture the full FOV)*
* Frames per second: **4 fps**
* Bitrate: **~13 Mbps** *(you can change this value but you need to balance between your network bandwidth, number of cameras and frame quality)*

You may use my configuration and then tune it to your needs
****

## **2 - Q&A before you start** <a name="qa"></a>
### Why are you not using a cheap IP camera from eBay/Amazon/DealExtreme/Gearbest?
Although you can get quite cheap IP cameras there, this is quite simple to answer:
* I really do not want to add cameras to my private home that may stream to a cloud somewhere out of my home
* I want to avoid situations where you order 10 similar cameras, and when they arrive half of them come with a completely different firmware
* These cheap cameras have very little *(if any)* documentation available
* I really prefer to have full control over the equipment I own, which is not possible with a cheap IP plug-and-play camera

### Should I use a Raspberry Pi Zero or Zero W?
I would choose the **cheapest option** *(which is the non WiFi model in my case)* and buy a WiFi dongle on eBay.
The Raspberry Pi Zero W *(with embedded WiFi module)* has quite a lot of bugs that havent been solved since few years, so choose at your own risk.
Some reported issues with the embedded WiFi:
* [wlan freezes in raspberry pi 3/PiZeroW (Not 3B+)](https://github.com/raspberrypi/linux/issues/1342)
* [Kernel oops or hard freeze when streaming video on Zero W (and Pi 3B+)](https://github.com/raspberrypi/linux/issues/2555)

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

Here are some diagrams to show the main differences between MJPEG and H.264.
The first one shows the quality and bandwith needed for each encoding method. Note the degrading quality of the H.264:

![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/codecs1.png "MJPEG vs H.264")

The second one shows what happens in case of a dropped frame. On a MJPEG stream, the stream simply pauses (or goes black) and waits for the next frame, on an H.264 stream the lack of the key frame will corrupt the next frames untill a new key frame is received:

![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/codecs2.png "MJPEG vs H.264")

For my cameras **I decided to go with MJPEG** because I am more interested in having **sharp image quality** per frame rather than bandwidth efficiency.
Also in case some frames are dropped I prefer to have the **instant recovery that MJPEG offers** rather than the few seconds of corrupted images from the H.264 when operating at a low framerate. 
I am using a low framerate *(~4 fps)* and ZoneMinder will take care of encoding into H.264 in order to store the footage.
According to ZM website unless you have a powerful server to handle H.264, just **stick with MJPEG cameras**.
For my setup the bandwidth is not really an issue as I will have separate networks for surveilance + IOT and for general use *(laptop, TV, phones, etc)* so MJPEG was the choice.

****

## **3 - Cost breakdown** <a name="cost"></a>

*NOTE: As I live in Poland, I bought some elements directly from Polish websites (such as Allegro.pl and Botland.pl)*
The prices are listed as of 30th April 2019

### **Raspberry Pi Zero or Pi Zero W?**

After analysing the costs of a Raspberry Pi Zero and a Zero W, I decided to go for a Zero + WiFi module + OTG adapter as it was a cheaper option.

Part | Raspberry Pi Zero | Raspberry Pi Zero W
--- | --- | --- 
Raspberry Pi Board | $6.79 | $13.58
USB WiFi module | $1.39 | -
MicroUSB-USB OTG adapter | $0.33 | -
**TOTAL** | **$8.51** | **$13.58**

### **Indoor camera**

These are the costs of my indoor camera module, with day and night vision (with electronic IR cut filter).
I am not including the cost of any dummy camera enclosure as I designed and 3D printed my own enclosure, which you can download from the 3D printing section.

Part | Price/each
--- | ---
Raspberry Pi Zero | $6.79
USB WiFi module | $1.39
MicroUSB-USB OTG adapter *(3-pack)* | $0.33
MicroSD 4GB *(used)* | $2.24
IR 850nm 36 LED ring *(5-pack)* | $2.6
5MP OV5647 camera with IR-CUT switch | $10.61
Rpi Zero camera cable adapter *(4-pack)* | $1.23
**TOTAL** | **$25.19** *(€22.47 / 96.30 zł)*

### **Where to buy?**
Item | Store | Link
--- | --- | ---
Raspberry Pi Zero | Botland (PL) | [Link](https://botland.com.pl/)
MicroSD 4GB *(used)* | Allegro (PL) | [Link](https://allegro.pl/)
Remaining items | eBay | [Link](https://www.ebay.com/)

****

## **4 - Requirements** <a name="requirements"></a>

![alt text](https://raw.githubusercontent.com/vascojdb/pizero-zoneminder-cam/master/resources/image_elements.PNG "What you will need")

For this setup you will need:
1. Raspberry Pi Zero *(or Zero W)*
2. Micro SD card *(2GB or 4GB is good enough)*
2. USB WiFi stick/module + Micro USB OTG adapter *(if you are using the non-WiFi version)*
3. Raspberry Pi Camera
4. USB power supply
6. Screen *(with HDMI cable and mini-HDMI adapter)*

****

## **5 - Installation** <a name="installation"></a>

Let's start by preparing the micro SD card with the latest MotionEyeOS image:
1. Download the latest **MotionEyeOS** *(Wiki page [here](https://github.com/ccrisan/motioneyeos/wiki))* from *ccrisan* GitHub releases page [here](https://github.com/ccrisan/motioneyeos/releases). Under *Assets* you should select the apropriate image *(motioneyeos-raspberrypi-YYYYMMDD.img.xz)* in our case.
2. Extract the XZ file somewhere on your computer using a tool like 7-ZIP, which you can download [here](https://www.7-zip.org/download.html), you will be left with an IMG file.
3. Now use a tool like **Win32 Disk Imager** ([download here](https://sourceforge.net/projects/win32diskimager/)) or similar to burn the IMG file into your micro SD card.
4. **Important:** Before you remove your SD card you need to configure your WiFi network, to do this follow the guide from MotionEyeOS [here](https://github.com/ccrisan/motioneyeos/wiki/Wifi-Preconfiguration)

## **6 - MotionEyeOS configuration** <a name="motioneyeos"></a>

Let's configure the MotionEyeOS basics with these steps:
1. Put the micro SD on your Raspberry Pi Zero and connect it to your HDMI screen
2. *Skip this step if you are using a Raspberry Pi Zero W with embedded WiFi:* Add your WiFi USB dongle
3. Power up the Raspberry Pi, wait some minutes and take note of the assigned IP on the screen *(the IP will be assigned automatically via DHCP from your network)*
4. Open your browser on your PC and point to the ip *(for example: http://192.168.0.123/)*
5. On the login screen, login with user `admin` and an empty password
6. When the main page opens, navigate to **General Settings** and change **Advanced Settings** to **ON**
7. Edit here the username and password for the administrator and the view-only user *(if needed)*
8. Change your **Time Zone** to the correct value according to where you are on the world
9. You can specify the camera hostname on the **Hostname** field, although it is not really needed
10. Navigate to **Network** and set here a static IP for your camera by changing **IP Configuration** to **Manual (Static IP)**
11. Set your desired static IP, Network Mask, Gateway and DNS server *(for example IP:192.168.0.123, Mask:255.255.255.0, Gateway:192.168.0.1, DNS:8.8.8.8)*. A good approach is to create some spreadsheet with all the static IPs on your network.
12. Navigate to **Services** and set **Enable FTP Server** and **Enable Samba Server** to **OFF** *(you can keep the SSH service ON in case you need to make some maintenance in the future)*
13. Navigate to **Expert Settings** and turn **Fast Network Camera** to **ON**
14. Press the **Apply** button and confirm the reboot, wait a few minutes and log in again.
15. Navigate to **Video Device** and edit your settings according to your preferences. These are the settings I use on my cameras:
```
Video Device tab
   * Video Resolution: 2592x1944
   * Frame Rate: 4
   * Image Quality: 10% (this gives about 13Mbps for the MJPEG stream)
   * Exposure Mode: Fixed FPS (so it avoids the frame drops and motion blur when it is getting dark)
   * Dynamic Range Compensation: High
```
16. Navigate to **Video Streaming** section and set the port here if needed, I left the default one *(8081)*
17. Click on **Streaming URL** and copy the contents as you will need them later for ZoneMinder.
18. Press the **Apply** button *(you may need to reboot again)*

## **7 - ZoneMinder configuration** <a name="zm"></a>

Follow these steps to add the cameras to ZoneMinder:
1. Login to your ZoneMinder instance
2. Click the **Add** button to add a new camera
3. Fill all the data according to your preferences, and just set the following parameters:
```
General tab
   * Source Type: Ffmpeg
   * Analysis FPS: 4 (chane to whatever FPS you selected)
   * Maximum FPS and Alarm Maximum FPS: 8 (usually I set it to a value a bit higher than the camera FPS)
 
Source tab
   * Source Path: Use the Streaming URL you got from MotionEye here *(example: http://192.168.0.31:8081/)*
   * Method: TCP
   * Target colorspace: 24 bit color
   * Capture Width: 2592 (use whatever resolution you selected on MotionEye)
   * Capture Height: 1944 (use whatever resolution you selected on MotionEye)

Storage tab
   * Video Writer: X264 Encode
   * Optional Encoder parameters: crf=30 (adjust to what fits you better, 18-28 are usually used, higher value means more compression, 30 gives me about 1.7-2.2Mbps and quality is quite good)
```
4. Press **Apply** and you should be all set!

****

## **8 - Building the camera enclosure** <a name="enclosure"></a>

To build the camera enclosure you have 3 options:
* Leave the camera hardware as it is *(on open-air)*
* Buy a cheap dummy camera, remove the fake LEDs and the inside and add the Raspberry Pi Zero, camera and LEDs
* Design and 3D print your own enclosure

I did not want to have my hardware open-air, so I decided to buy a fake dome camera to use as enclosure. Unfortunatly the number of changes needed to accomodate the hardware was so big that I ended up designing and 3D printing some of the dummy camera parts.
After designing and 3D printing few parts I eventually decided to re-design and 3D print the whole indoor camera model.

You can download my designed 3D models (DWG and STL) from thingiverse from these links:
* Indoor camera: *TODO*

****

## **9 - Donate** <a name="donate"></a>
If you like this project, help me make it even better by donating!
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.me/vascojdb)
