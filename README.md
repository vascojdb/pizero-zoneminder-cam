# **PiZero-ZoneMinder-Cam** - Low cost ZoneMinder network camera using a Raspberry Pi Zero and a Pi camera

## Index
* [What is the PiZero-ZoneMinder-Cam?](#id1)
* [Q&A before you start](#id2)
* [Cost breakdown](#id3)
* [Installation](#id4)
* [Donate](#id10)

## What is the PiZero-ZoneMinder-Cam?
It is a very low cost camera built from a Raspberry Pi Zero, a Raspberry Pi camera and a cheap USB-WiFi module.

This setup is meant to be connected to a ZoneMinder server you have on your network, where you can configure your cameras (recording, movement detection, etc) as you please.
I abandoned some ready to use software/builds available online because of how heavy they are. I also avoided cheap IP cameras because I do not want my private home cameras connected to a cloud.

## Q&A before you start
### Why I am not using MotionEye or MotionEyeOS?
I have tried these tools, but I abandoned them because they:
* Were quite heavy and extremelly slow on a Raspberry Pi Zero, as most part of the tasks were CPU intensive
* Included features like motion detection, text overlay, video recording, which I was not planning to run on-camera
* Provided dissapointing H264 results with lots of artifacts which are very unreliable for motion detection
* Provided MJPEG option with very basic setup and didn't offer a lot of configuration options

### Why am I not using a cheap IP camera from eBay?
This is quite simple to answer:
* I really do not want to add cameras to my private home that may transmit a stream to a cloud somewhere out of my home.
* I do not want the footage to leave my domain.
* I really prefer to have full control over the equipment I own, which is not possible with a cheap IP plug-and-play camera.

### Why am I using a non-WiFi Raspberry Pi Zero (non-W model)?
The Raspberry Pi Zero W (with embedded WiFi module) has quite a lot of bugs that havent been solved since few years, for example:
* [wlan freezes in raspberry pi 3/PiZeroW (Not 3B+)](https://github.com/raspberrypi/linux/issues/1342)
* [Kernel oops or hard freeze when streaming video on Zero W (and Pi 3B+)](https://github.com/raspberrypi/linux/issues/2555)

From my personal tests, the Raspberry Pi Zero W would always crash the network interface few minutes after streaming video over WiFi, which was only resolved via a full reboot. I decided that this solution was very unreliable for a device that is supposed to stay online 24/7 without human contact.
I then decided to test one of those cheap USB-WiFi dongles, which worked perfectly without any drop *(tested with constant 5Mbps upload)*

## Cost breakdown
*NOTE: As I live in Poland, I bought some elements directly from Polish websites, so the prices will appear in PLN. Buying the Raspberry Pi Zero and the Micro SD card were cheaper to buy in Poland rather than eBay, so I didn't include eBay prices for them.*
The prices are listed as of 19th April 2019

### Price for each option
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

### Totals
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

### Where to buy?
Item | Store | Link
--- | --- | ---
Raspberry Pi Zero | Botland (PL) | [Link](https://botland.com.pl/en/modules-and-kits-raspberry-pi-zero/5215-raspberry-pi-zero-v13-512mb-ram.html)
Kingston 16GB C10 U1 | Allegro (PL) | [Link](https://allegro.pl/oferta/kingston-karta-microsd-16gb-micro-adapter-sd-7849829127)
OV5647 cameras | Botland (PL) | [Link](https://botland.com.pl/en/945-cameras-for-raspberry-pi)
OV5647 cameras | eBay | [Link](https://www.ebay.com/)

## Installation
Available soon

## Donate
If you like this project, help me make it even better by donating!
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.me/vascojdb)

