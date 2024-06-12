#!/bin/bash

# Verifieer of de gebruiker root is
if [ "$(id -u)" -ne 0 ]; then
        echo 'Script must be ran by root'>&2
        exit 1
fi

# Herstel iptables regels
iptables-restore < ~/rules.v4
ip6tables-restore < ~/rules.v6

# Kopieer de python script naar juist folder
cp /home/warden/startup_code/block.py /root/.mitmproxy/

# Start de mitmproxy
mitmdump --mode transparent --showhost -s /root/.mitmproxy/block.py &
