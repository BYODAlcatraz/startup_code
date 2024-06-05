#!/bin/bash
set -e
# Verifieer of de gebruiker root is
if [ "$(id -u)" -ne 0 ]; then
	echo 'Script must be ran by root'>&2
	exit 1
fi


# Verdediging tegen booten in single user mode
read -s -p "Enter password: " passwd
echo 

HASHPW=$(echo -e "$passwd\n$passwd" | LC_ALL=C /usr/bin/grub-mkpasswd-pbkdf2 | awk '/hash of / {print $NF}')

echo "set superusers=root" | tee -a /etc/grub.d/40_custom
echo "password_pbkdf2 root $HASHPW" | tee -a /etc/grub.d/40_custom

sudo sed -i '/^CLASS=/ s/"$/ --unrestricted"/' /etc/grub.d/10_linux

update-grub

# Verwijder overtollige software
apt-get purge *nanum konqueror kmail gimp khelpcenter okular korganizer goldendict akregator kaddressbook kmouth knotes kwalletmanager pim-data-exporter kdeconnect kasumi –y

apt autoremove

# Update het systeem en de packages
apt update && apt upgrade

# Installeer vscode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg 
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg 
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null 
rm -f packages.microsoft.gpg

apt install apt-transport-https
apt update
apt install code

# # Installeer pgAdmin
# curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

# sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'

# apt install pgadmin4

# apt install pgadmin4-desktop

# Voeg de prisoner user toe
useradd -m -s /bin/bash prisoner

# Set the user's password
echo prisoner:prisoner | chpasswd



# Compileer het start programma

cd /home/warden/startup_code

gcc -o startup startup.c

# Configureer het python script om uitgevoerd te worden bij startup
mkdir /home/prisoner/.startup_code
mv /home/warden/startup_code/startup /home/prisoner/.startup_code
chmod 4711 /home/warden/startup_code/startup
mkdir -p /home/prisoner/.config/autostart
echo "[Desktop Entry]\nExec=/home/prisoner/.startup_code/startup\nIcon=\nName=Startupscript\nPath=\nTerminal=False\nType=Application" > /home/prisoner/.config/autostart/startupscript.desktop

# installeer ansible
apt install ansible


# VOOR execute python with root permission
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

#int main()
#{
#   setuid( 0 );
#   system( "/path/to/script.sh" ); 

#    return 0;
# }

# Install gcc (apt-get install gcc on debian based distro's), then type

# gcc -o runscript runscript.c

# Now, as root, type

# chown root:root runscript script.sh
# chmod 4755 runscript script.sh

# SQUID verder instellen onder andere squid reconfigure

# Bestanden die restricted moeten zijn voor prisoner moeten door root 700 permissies krijgen
#vb root@alcatraz chmod 700 curl
