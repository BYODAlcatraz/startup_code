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
nohup /home/warden/startup_code/start_mitm.sh

while true; do
	sleep 1
	if [ ps -Al | grep mitmdump ]
	then
		echo "running" >> /home/student/log.txt
	else
		echo "starting" >> /home/student/log.txt
		nohup /home/warden/startup_code/start_mitm.sh
	fi
done

