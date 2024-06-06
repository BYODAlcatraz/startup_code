#!/bin/bash

# Installeer squid met de juiste ssl flags
apt install squid-openssl -y
# Voeg eventueel al whitelisted paginas toe
echo "" > /etc/squid/whitelist.txt
echo ".toledo.ucll.be" >> /etc/squid/whitelist.txt
echo ".kuleuven.be" >> /etc/squid/whitelist.txt

# Voeg whitelist acl regels toe aan squid.conf (bovenkant)
sed -i '1s/^/http_access deny !whitelist\n/' /etc/squid/squid.conf
sed -i '1s/^/acl whitelist dstdomain \"\/etc\/squid\/whitelist.txt\"\n/' /etc/squid/squid.conf
squid -k reconfigure

# We maken een self-signed certificaat aan
cd /etc/squid
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout bump.key -out bump.crt \
	-subj "/C=BE/ST=VlaamsBrabant/L=Leuven/O=Test/CN=UCLL"
openssl x509 -in bump.crt -outform DER -out bump.der
chown proxy:proxy bump*
chmod 444 bump*

# We maken een database voor de SSL-certificaten
service squid stop
mkdir -p /var/lib/squid
rm -rf /var/lib/squid/ssl_db
/usr/lib/squid/security_file_certgen -c -s /var/lib/squid/ssl_db -M 20MB
chown -R proxy:proxy /var/lib/squid

# Nog enkele aanpassingen aan squid.conf
sed -i '3s/^/acl intermediate_fetching transaction_initiator certificate-fetching\n/' /etc/squid/squid.conf
sed -i '4s/^/http_access allow intermediate_fetching\n/' /etc/squid/squid.conf
echo "sslcrtd_program /usr/lib/squid/security_file_certgen -s /var/lib/squid/ssl_db -M 20MB" >> /etc/squid/squid.conf
echo "sslproxy_cert_error allow all" >> /etc/squid/squid.conf		
echo "ssl_bump stare all" >> /etc/squid/squid.conf	
sed -i '/http_port 3128/c\http_port 3128 tcpkeepalive=60,30,3 ssl-bump generate-host-certificates=on dynamic_cert_mem_cache_size=20MB tls-cert=\/etc\/squid\/bump.crt tls-key=\/etc\/squid\/bump.key cipher=HIGH:MEDIUM:!LOW:!RC4:!SEED:!IDEA:!3DES:!MD5:!EXP:!PSK:!DSS options=NO_TLSv1,NO_SSLv3,SINGLE_DH_USE,SINGLE_ECDH_USE tls-dh=prime256v1:\/etc\/squid\/bump_dhparam.pem\n' /etc/squid/squid.conf

# Nu nog de squid service restarten
service squid restart
squid -k reconfigure


# Zet lockprefs en policies in firefox
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
    "Proxy": {
      "AutoLogin": true,
      "HTTPProxy": "127.0.0.1:3128",
      "Mode": "manual",
      "SOCKSVersion": 4,
      "UseHTTPProxyForAllProtocols": true,
      "UseProxyForDNS": false
    },
    "Certificates": {
            "ImportEnterpriseRoots": true,
            "Install": [
                    "/etc/squid/bump.der"
            ]
    }
  }
}
' > /usr/lib/firefox-esr/distribution/policies.json

cd /usr/lib/firefox-esr/defaults/pref
echo '
//
pref("app.update.channel", "esr");
lockPref("network.proxy.type", 0); 
lockPref("network.proxy.http", "127.0.0.1"); 
lockPref("network.proxy.http_port", 3128); 
lockPref("network.proxy.socks", ""); 
lockPref("network.proxy.socks_port", 0); 
lockPref("network.proxy.ssl", "127.0.0.1"); 
lockPref("network.proxy.ssl_port", 3128); 
lockPref("network.proxy.share_proxy_settings", true); 
lockPref("network.proxy.no_proxies_on", ""); 
lockPref("network.proxy.socks_version", 5);
' > channel-prefs.js

openssl dhparam -out /etc/squid/bump_dhparam.pem -outform PEM 2048
squid -k reconfigure
echo -e "\033[0;32m OPERATION SUCCESSFULL! \033[0m"
