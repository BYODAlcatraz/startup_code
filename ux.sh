#!/bin/bash

# enable dock settings extension
gnome-extensions enable dash-to-dock@micxgx.gmail.com

# lock dock to bottom
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true

# set wallpaper
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/wallpapers/wallpaper_exam.png'
