#!/bin/bash
#set -e
# Verifieer of de gebruiker root is
if [ "$(id -u)" -ne 0 ]; then
	echo 'Script must be ran by root'>&2
	exit 1
fi

# Configureer de 'source' voor de ansible scripts
DEFAULT_URL="https://byodAlcatraz.github.io/"
while getopts u:h flag
do
    case "${flag}" in
        u) url=${OPTARG};;
        h)
            echo 'USAGE: setup_debian.sh [-u url]'
            echo "-u url  url to get ansible exam configurations from (defaults to: \"$DEFAULT_URL\")"
            echo '-h      show this message'
            exit 0;;
    esac
done
if [ -z "$url" ]; then
    url=$DEFAULT_URL
fi
sed -i "/^PLAYBOOK_URL=\"\"$/s|\"\"|\"$url\"|" setup_examen.py

apt install -y python3-tk \
wget \
git \
vim \
gnome-shell-extension-dashtodock

# Functie voor te echo'en in roze tekst
print(){ value=${1}; echo -e "\033[38;5;201m${value}\033[0m"; }

# Voeg de users toe
print "Adding user student and warden"
useradd -m -s /bin/bash warden
usermod -aG sudo warden
useradd -m -s /bin/bash student

# Set the user's password
print "Setting student and warden passwords"
echo student:student | chpasswd
echo warden:warden | chpasswd

print "Copying startup code to /home/warden"
cp -r ../startup_code /home/warden/

# Verdediging tegen booten in single user mode
read -s -p "Enter password: " passwd
echo 

HASHPW=$(echo -e "$passwd\n$passwd" | LC_ALL=C /usr/bin/grub-mkpasswd-pbkdf2 | awk '/hash of / {print $NF}')

echo "set superusers=root" | tee -a /etc/grub.d/40_custom
echo "password_pbkdf2 root $HASHPW" | tee -a /etc/grub.d/40_custom
sed -i '/^CLASS=/ s/"$/ --unrestricted"/' /etc/grub.d/10_linux

# sed -i '/GRUB_TIMEOUT/c\GRUB_TIMEOUT\=0' /etc/default/grub
# sed -i '/GRUB_DEFAULT/iGRUB_DISABLE_SUBMENU\=y' /etc/default/grub

# update-grub

# Verwijder overtollige software
print "Removing unnessecary software"
apt-get purge -y calamares gnome-initial-setup gnome-2048 aisleriot cheese gnome-chess gnome-contacts five-or-more four-in-a-row gnome-nibbles xiterm+thai mlterm-common \
goldendict hitori gnome-klotski gnome-mahjongg gnome-mines gnome-maps seahorse quadrapassel iagno gnome-robots gnome-sudoku swell-foop tali gnome-taquin gnome-tetravex thunderbird

apt -y autoremove

apt-mark hold libreoffice*

# Update het systeem en de packages
print "Updating system packages"
apt -y update && apt -y upgrade

# Installeer vscode
print "Installing VS Code"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg 
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg 
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null 
rm -f packages.microsoft.gpg

apt install apt-transport-https
apt -y update
apt install -y code

# Compileer het start programma
print "Compiling startup code for startup program"
cd /home/warden/startup_code

gcc -o startup startup.c

# Configureer het python script om uitgevoerd te worden bij startup
print "Configuring startup python script to be ran at boot"
mkdir -p /home/student/.startup_code
mv /home/warden/startup_code/startup /home/student/.startup_code
mv /home/warden/startup_code/wallpaper_exam.png /usr/share/wallpapers
mkdir -p /home/student/.config/autostart
chown -R student:student /home/student/.config /home/student/.startup_code
chown root:root /home/student/.startup_code/startup
chmod 4711 /home/student/.startup_code/startup

desktop_entry="[Desktop Entry]
Type=Application
Exec=/home/student/.startup_code/startup
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=My script
Comment=Startup script"
echo "$desktop_entry" > /home/student/.config/autostart/startupscript.desktop


#Desktop entry voor Dock bar, wallpaper en timezone
print "Setting up wallpaper, configuring dock bar and setting timezone"
mv /home/warden/startup_code/ux.sh /home/student/.startup_code
chmod +x /home/student/.startup_code/ux.sh
desktop_entry="[Desktop Entry]
Type=Application
Exec=/home/student/.startup_code/ux.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=UX script
Comment=Startup script for UX"
echo "$desktop_entry" > /home/student/.config/autostart/ux.desktop

chown -R root:root /home/student/.config/autostart/

# installeer ansible
print "Installing Ansible"
apt -y install ansible

# Configureer mitmproxy
print "Configuring mitmproxy"

bash /home/warden/startup_code/setup_mitmproxy.sh

echo "[Unit]
Description=mitmproxy
[Service]
ExecStart=bash /home/warden/startup_code/start_mitmproxy.sh
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/mitmproxy.service
systemctl enable mitmproxy.service
systemctl disable udisks2.service


print "DONE!"

# # SQUID verder instellen onder andere squid reconfigure
# print "Further Squid Configuration"
# chmod +x /home/warden/startup_code/setup_squid.sh
# /home/warden/startup_code/setup_squid.sh

# Bestanden die restricted moeten zijn voor student moeten door root 700 permissies krijgen
#vb root@alcatraz chmod 700 curl

