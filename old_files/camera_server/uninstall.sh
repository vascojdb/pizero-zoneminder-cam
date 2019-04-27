#!/bin/bash

if [ "$EUID" -ne 0 ]
then
  echo "This uninstallation script can only be run as root or with sudo!"
  exit
fi

echo "Uninstalling PiZero-ZoneMinder-Cam..."

echo "> Stopping service"
systemctl pizero-zm-cam stop

echo "> Disabling service"
systemctl disable pizero-zm-cam

echo "> Removing service"
rm /etc/systemd/system/pizero-zm-cam.service
systemctl daemon-reload

echo "> Removing 'pizero-zm-cam'"
rm /usr/local/sbin/pizero-zm-cam

echo "> Removing 'pizero-zm-cam.conf'"
rm /etc/pizero-zm-cam.conf

echo "PiZero-ZoneMinder-Cam is now uninstalled!"
echo "Exiting..."
