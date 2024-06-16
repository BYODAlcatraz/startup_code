#!/bin/bash

# enable dock settings extension
gnome-extensions enable dash-to-dock@micxgx.gmail.com

#Set the right keyboard layouts
gsettings reset org.gnome.desktop.input-sources sources
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'be'), ('xkb', 'us')]"

# lock dock to bottom
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true


# Add minimize and maximize buttons
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"

# Open settings for wifi
