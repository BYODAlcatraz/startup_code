#!/bin/bash

cd /home/warden/startup_code/
su - prisoner -c "mkdir /home/prisoner/Pictures"
su - prisoner -c "cp /home/warden/startup_code/wallpaper_exam.png /home/prisoner/Pictures"
su - prisoner -c "kwriteconfig5 --file '/home/prisoner/.config/plasma-org.kde.plasma.desktop-appletsrc'\
 --group 'Containments' --group '1' --group 'Wallpaper' --group 'org.kde.image' --group 'General'\
 --key 'Image' '/home/prisoner/Pictures/wallpaper_exam.png'"
