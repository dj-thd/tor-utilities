#!/bin/bash

# Set iptables and services to not exit through tor

echo "Flushing iptables..."
iptables -t nat -F
iptables -F
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT

echo "Stopping tor..."
service tor stop

echo "Restarting network..."
service networking restart
service NetworkManager restart

sleep 5

echo -ne "Public IP: "
OLD_IP="$(echo -ne "GET /text HTTP/1.1\r\nHost: wtfismyip.com\r\nConnection: close\r\n\r\n" | nc wtfismyip.com 80 | tail -n -1)"
echo "$OLD_IP"

