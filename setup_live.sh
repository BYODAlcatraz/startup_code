#!/bin/bash
 
cd /tmp
 
git clone https://github.com/Tomas-M/linux-live.git
 
cd /tmp/linux-live
 
# Verifieer of de gebruiker root is
if [ "$(id -u)" -ne 0 ]; then
        echo 'Script must be ran by root'>&2
        exit 1
fi
 
apt install squashfs-tools
apt install mkisofs
 
bash /tmp/linux-live/build

bash
 
lsblk -d -o NAME,SIZE | awk 'NR>1 {print $1 ": " $2}'
echo "Please insert USB drive and press any key to continue"
read -n 1 -s
 
while true; do
        echo -e "\033[0;32m"
        lsblk -d -o NAME,SIZE | awk 'NR>1 {print $1 ": " $2}'
        echo -e "\033[0m"
        read -p "Please confirm the stick to be formatted by typing it's name (sda, sdb, sdc, ...) below. Type \"r\" to reload devices: " disk
        if [ ${disk,,} == r ]; then
                continue
        fi
 
        read -p "Selected device is $disk, continue? [Y/n]: " confirmed
 
        if [ ${confirmed,,} == y ]; then
                break
        else
                continue
        fi
done
 
 
echo "Formatting /dev/$disk now..."
 
umount /dev/$disk*
mkfs.ext4 /dev/$disk -F
 
mkdir -p /media/warden/live_usb
mount /dev/$disk /media/warden/live_usb
 
cp -r /tmp/linux-data*/linux/ /media/warden/live_usb/
 
bash /media/warden/live_usb/linux/boot/bootinst.sh

umount /media/warden/live_usb
