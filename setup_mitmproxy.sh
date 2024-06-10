#!/bin/bash

# Download mitmproxy
apt install mitmproxy

# Download iptables
apt install iptables

# Redirect HTTP en HTTPS naar mitm
iptables -t nat -A OUTPUT -p tcp -m owner --uid-owner student --dport 80 -j REDIRECT --to-port 8080
iptables -t nat -A OUTPUT -p tcp -m owner --uid-owner student --dport 443 -j REDIRECT --to-port 8080
ip6tables -t nat -A OUTPUT -p tcp -m owner --uid-owner student --dport 80 -j REDIRECT --to-port 8080
ip6tables -t nat -A OUTPUT -p tcp -m owner --uid-owner student --dport 443 -j REDIRECT --to-port 8080

