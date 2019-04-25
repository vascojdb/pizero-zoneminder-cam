#!/bin/bash

if [ "$EUID" -ne 0 ]
then
  echo "This installation script can only be run as root or with sudo!"
  exit
fi

echo "Installing PiZero-ZoneMinder-Cam..."

echo "> Copying 'pizero-zm-cam' to /usr/local/sbin/pizero-zm-cam"
cp pizero-zm-cam /usr/local/sbin/
chmod +x /usr/local/sbin/pizero-zm-cam

echo "> Copying 'pizero-zm-cam.conf' to /usr/etc/pizero-zm-cam.conf"
cp pizero-zm-cam.conf /etc/

echo "> Installing service"
cp pizero-zm-cam.service /etc/systemd/system/
systemctl daemon-reload

echo "> Enabling service"
systemctl enable pizero-zm-cam

echo "PiZero-ZoneMinder-Cam is now installed!"
echo "> To start/stop/restart the service type: sudo systemctl start/stop/restart pizero-zm-cam"
echo "> To enable/disable the service autostart on boot: sudo systemctl enable/disable pizero-zm-cam"
echo "Exiting..."
