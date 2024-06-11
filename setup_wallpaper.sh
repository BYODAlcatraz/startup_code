#!/bin/bash
su student -c gsettings get org.gnome.desktop.background picture-uri 'file:///usr/share/wallpapers/wallpaper_exam.png'


# mkdir -p /etc/dconf/profile
# mkdir -p /etc/dconf/db/local.d


# echo "user-db:user
# system-db:local" > /etc/dconf/profile/user

# echo "[org/gnome/desktop/background]
# picture-uri='file:///user/share/wallpapers/wallpaper_exam.png'" > /etc/dconf/db/local.d/00-wallpaper

# chmod 644 /usr/share/wallpapers/wallpaper_exam.png

# dconf update
