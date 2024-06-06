#!/bin/bash

cd /home/warden/startup_code/
su - prisoner -c "mkdir -p /home/prisoner/Pictures"
cp /home/warden/startup_code/wallpaper_exam.png /home/prisoner/Pictures
su - prisoner -c "kwriteconfig5 --file '/home/prisoner/.config/plasma-org.kde.plasma.desktop-appletsrc'\
 --group 'Containments' --group '1' --group 'Wallpaper' --group 'org.kde.image' --group 'General'\
 --key 'Image' '/home/prisoner/Pictures/wallpaper_exam.png'"

su - warden -c "mkdir -p /home/warden/Pictures"
cp /home/warden/startup_code/wallpaper_exam.png /home/warden/Pictures
su - warden -c "kwriteconfig5 --file '/home/warden/.config/plasma-org.kde.plasma.desktop-appletsrc'\
 --group 'Containments' --group '1' --group 'Wallpaper' --group 'org.kde.image' --group 'General'\
 --key 'Image' '/home/warden/Pictures/wallpaper_exam.png'"
