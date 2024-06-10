#!/bin/bash
#set -e
# Verifieer of de gebruiker root is
if [ "$(id -u)" -ne 0 ]; then
	echo 'Script must be ran by root'>&2
	exit 1
fi

# Voeg de prisoner user toe
echo -e "\033[38;5;201m Adding prisoner and warden users \033[0m"
useradd -m -s /bin/bash warden
useradd -m -s /bin/bash prisoner

# Set the user's password
echo -e "\033[38;5;201m Setting prisoner and warden passwords \033[0m"
echo prisoner:prisoner | chpasswd
echo warden:warden | chpasswd

echo -e "\033[38;5;201m Copying startup code folder to /home/warden \033[0m"
cp -r ../startup_code /home/warden/

# Verdediging tegen booten in single user mode
#read -s -p "Enter password: " passwd
#echo 

#HASHPW=$(echo -e "$passwd\n$passwd" | LC_ALL=C /usr/bin/grub-mkpasswd-pbkdf2 | awk '/hash of / {print $NF}')

#echo "set superusers=root" | tee -a /etc/grub.d/40_custom
#echo "password_pbkdf2 root $HASHPW" | tee -a /etc/grub.d/40_custom

# sed -i '/^CLASS=/ s/"$/ --unrestricted"/' /etc/grub.d/10_linux
# sed -i '/GRUB_TIMEOUT/c\GRUB_TIMEOUT\=0' /etc/default/grub
# sed -i '/GRUB_DEFAULT/iGRUB_DISABLE_SUBMENU\=y' /etc/default/grub

# update-grub

# Verwijder overtollige software
echo -e "\033[38;5;201m Removing unnecessary software \033[0m"
apt-get purge -y *nanum konqueror kmail gimp khelpcenter okular korganizer goldendict akregator kaddressbook kmouth knotes kwalletmanager pim-data-exporter kdeconnect kasumi

apt -y autoremove


# Update het systeem en de packages
echo -e "\033[38;5;201m Updating system and packages \033[0m"
apt -y update && apt -y upgrade

apt install -y gcc
apt install -y python3-tk
apt install -y curl
apt install -y wget

# Installeer vscode
echo -e "\033[38;5;201m Installing VSCode \033[0m"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg 
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg 
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null 
rm -f packages.microsoft.gpg

apt install apt-transport-https
apt -y update
apt install -y code

# # Installeer pgAdmin
# curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

# sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'

# apt install pgadmin4

# apt install pgadmin4-desktop

# Disable de Nouveau drivers
echo -e "\033[38;5;201m Disabling Nouveau drivers \033[0m"
touch /etc/modprobe.d/blacklist-nouveau.conf
echo "options nouveau modeset=0" > /etc/modprobe.d/blacklist-nouveau.conf
echo "blacklist nouveau" >> /etc/modules.conf.d/15-blacklist-nouveau.conf
update-initramfs -u

# Compileer het start programma
echo -e "\033[38;5;201m Compiling startprogram for startup code \033[0m"
cd /home/warden/startup_code

gcc -o startup startup.c

# Configureer het python script om uitgevoerd te worden bij startup
echo -e "\033[38;5;201m Configuring python script to be ran at startup \033[0m"
mkdir -p /home/prisoner/.startup_code
mv /home/warden/startup_code/startup /home/prisoner/.startup_code
mkdir -p /home/prisoner/.config/autostart
chown -R prisoner:prisoner /home/prisoner/.config /home/prisoner/.startup_code
chown root:root /home/prisoner/.startup_code/startup
chmod 4711 /home/prisoner/.startup_code/startup
desktop_entry="[Desktop Entry]
Exec=/home/prisoner/.startup_code/startup
Icon=
Name=Startupscript
Path=
Terminal=False
Type=Application"
echo "$desktop_entry" > /home/prisoner/.config/autostart/startupscript.desktop

# installeer ansible
echo -e "\033[38;5;201m Installing Ansible \033[0m"
apt -y install ansible

# Stel examen achtergrond in
echo -e "\033[38;5;201m Setting Exam wallpaper \033[0m"
./setup_wallpaper.sh

# SQUID verder instellen onder andere squid reconfigure
echo -e "\033[38;5;201m Further Squid configuration \033[0m"
chmod +x /home/warden/startup_code/setup_squid.sh
/home/warden/startup_code/setup_squid.sh

# Bestanden die restricted moeten zijn voor prisoner moeten door root 700 permissies krijgen
#vb root@alcatraz chmod 700 curl

