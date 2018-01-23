#!/bin/bash

# Check your public IP

echo -ne "Public IP: "
OLD_IP="$(echo -ne "GET /text HTTP/1.1\r\nHost: wtfismyip.com\r\nConnection: close\r\n\r\n" | nc wtfismyip.com 80 | tail -n -1)"
echo "$OLD_IP"

whois "$OLD_IP"
