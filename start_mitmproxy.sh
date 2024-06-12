#!/bin/bash

# Verifieer of de gebruiker root is
if [ "$(id -u)" -ne 0 ]; then
        echo 'Script must be ran by root'>&2
        exit 1
fi

# Herstel iptables regels
iptables-restore < ~/rules.v4
ip6tables-restore < ~/rules.v6

# Start de mitmproxy
chmod +x /home/warden/startup_code/start_mitm.sh
nohup /home/warden/startup_code/start_mitm.sh
# mitmdump --mode transparent --showhost -s /root/.mitmproxy/block.py > /home/student/kakapipidiraree.txt &