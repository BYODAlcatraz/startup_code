#!/bin/bash

cd /tmp

git clone https://github.com/Tomas-M/linux-live.git

cd /tmp/linux-live

# Verifieer of de gebruiker root is
if [ "$(id -u)" -ne 0 ]; then
	echo 'Script must be ran by root'>&2
	exit 1
fi

bash /tmp/linux-live/build

apt install squashfs-tools
apt install mkisofs
 
 
lsblk -d -o NAME,SIZE | awk 'NR>1 {print $1 ": " $2}'
echo "Please insert USB drive and press enter"
read -n 1 -s
lsblk -d -o NAME,SIZE | awk 'NR>1 {print $1 ": " $2}'
read -p "Please confirm the stick to be formatted by typing it's name (sda, sdb, sdc, ...) below: " disk
echo "Formatting /dev/$disk now..."
umount /dev/$disk*
mkfs.ext4 /dev/$disk -F
 
mkdir -p /media/warden/live_usb
mount /dev/$disk /media/warden/live_usb

cp -r /tmp/linux-data*/linux/ /media/warden/live_usb/

bash /media/warden/live_usb/linux/boot/bootinst.sh