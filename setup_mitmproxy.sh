#!/bin/bash

# Verifieer of de gebruiker root is
if [ "$(id -u)" -ne 0 ]; then
        echo 'Script must be ran by root'>&2
        exit 1
fi

# Download mitmproxy
apt install -y mitmproxy

# Download iptables
apt install -y iptables

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf

# Flush iptables
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

ip6tables -F
ip6tables -X
ip6tables -t nat -F
ip6tables -t nat -X
ip6tables -P INPUT ACCEPT
ip6tables -P OUTPUT ACCEPT
ip6tables -P FORWARD ACCEPT

# Redirect alles naar mitm
iptables -t nat -A OUTPUT -p tcp -m owner --uid-owner student -j REDIRECT --to-port 8080
iptables -t nat -A OUTPUT -p udp -m owner --uid-owner student -j REDIRECT --to-port 8080 ! --dport 53
iptables -t nat -A OUTPUT -p icmp -m owner --uid-owner student -j REDIRECT --to-port 8080

ip6tables -t nat -A OUTPUT -p tcp -m owner --uid-owner student -j REDIRECT --to-port 8080
ip6tables -t nat -A OUTPUT -p udp -m owner --uid-owner student -j REDIRECT --to-port 8080 ! --dport 53
ip6tables -t nat -A OUTPUT -p icmp -m owner --uid-owner student -j REDIRECT --to-port 8080

# Save rules to file
iptables-save > /root/rules.v4
ip6tables-save > /root/rules.v6

# Start mitmproxy om configuratie bestanden te laten genereren
mitmdump --mode transparent &
sleep 5
pkill mitmdump

# Configureer Firefox instellingen en importeer ca certificaat
mkdir -p /etc/ca-certificates
openssl x509 -in /root/.mitmproxy/mitmproxy-ca-cert.pem -outform DER -out /etc/ca-certificates/mitmproxy-ca-cert.der
echo '
{
  "policies": {
    "BlockAboutAddons": true,
    "BlockAboutConfig": true,
    "BlockAboutProfiles": true,
    "BlockAboutSupport": true,
    "DefaultDownloadDirectory": "${home}/Downloads",
    "DisableDeveloperTools": true,
    "DisableFeedbackCommands": true,
    "DisableFirefoxAccounts": true,
    "DisableForgetButton": true,
    "DisableFormHistory": true,
    "DisableMasterPasswordCreation": true,
    "DisablePocket": true,
    "DisablePrivateBrowsing": true,
    "DisableProfileImport": true,
    "DisableSetDesktopBackground": true,
    "DownloadDirectory": "${home}/Downloads",
    "Certificates": {
            "ImportEnterpriseRoots": true,
            "Install": [
                    "/etc/ca-certificates/mitmproxy-ca-cert.der"
            ]
    }
  }
}
' > /usr/lib/firefox-esr/distribution/policies.json

# Kopieer het blokkeer python script naar juiste folder
cp /home/warden/startup_code/block.py /root/.mitmproxy/

# Kopieer de blokkeerpagina naar de juiste folder
cp /home/warden/startup_code/access_denied.html /root/.mitmproxy/
cp /home/warden/startup_code/ucll_logo.png /root/.mitmproxy/
