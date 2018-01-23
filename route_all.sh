#!/bin/bash

# Set iptables to route all traffic through tor

echo -ne "Previous IP: "
OLD_IP="$(echo -ne "GET /text HTTP/1.1\r\nHost: wtfismyip.com\r\nConnection: close\r\n\r\n" | nc wtfismyip.com 80 | tail -n -1)"
echo "$OLD_IP"

if [[ "$OLD_IP" == "" ]]; then
	echo "Error getting old ip! Aborting"
	exit
fi

_non_tor="192.168.0.0/16 10.0.0.0/8 172.16.0.0/12"
_tor_uid="debian-tor"
_trans_port="9040"

# cleanup
iptables -F
iptables -t nat -F

#### NAT
# TOR can exit internet
iptables -t nat -A OUTPUT -m owner --uid-owner "$_tor_uid" -j RETURN

# redirect 53 to tor port
iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 53

# bypass clearnets
for _clearnet in $_non_tor 127.0.0.0/8; do
	iptables -t nat -A OUTPUT -d "$_clearnet" -j RETURN
done

# redirect traffic
iptables -t nat -A OUTPUT -p tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports "$_trans_port"

#### FILTER
# keep related, established output
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# bypass clearnet output
for _clearnet in $_non_tor 127.0.0.0/8; do
	iptables -A OUTPUT -d "$_clearnet" -j ACCEPT
done

# bypass TOR output
iptables -A OUTPUT -m owner --uid-owner "$_tor_uid" -j ACCEPT

# reject other outputs
iptables -A OUTPUT -j REJECT

# keep related, established input
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Accept DNS traffic
iptables -A INPUT -p udp --dport 53 -j ACCEPT

# Accept transport traffic
iptables -A INPUT -p tcp --dport "$_trans_port" -j ACCEPT

# Accept control port traffic from loopback
iptables -A INPUT -s 127.0.0.0/8 -d 127.0.0.1 -p tcp --dport 9051 -j ACCEPT

# Reject any more traffic
iptables -A INPUT -j REJECT

# Set policies
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

echo "nameserver 127.0.0.1" > /etc/resolv.conf

echo "Starting service..."

rm /var/log/tor/notices.log
service tor restart

sleep 5

tail -f /var/log/tor/notices.log | grep -m 1 "Bootstrapped 100%" >/dev/null

echo -ne "New IP: "
NEW_IP="$(echo -ne "GET /text HTTP/1.1\r\nHost: wtfismyip.com\r\nConnection: close\r\n\r\n" | nc wtfismyip.com 80 | tail -n -1)"
echo "$NEW_IP"

if [[ "$OLD_IP" != "$NEW_IP" ]]; then
	echo "Tor is connected correctly"
else
	echo "Error connecting tor! reverting..."
	iptables -t nat -F
	iptables -F
	service networking restart
	service tor stop
	exit
fi
