#!/bin/bash

# Change tor exit node without restarting tor service

echo -ne "Previous IP: "
OLD_IP="$(echo -ne "GET /text HTTP/1.1\r\nHost: wtfismyip.com\r\nConnection: close\r\n\r\n" | nc wtfismyip.com 80 | tail -n -1)"
echo "$OLD_IP"

if [[ "$OLD_IP" == "" ]]; then
        echo "Error getting old ip! Aborting"
	exit
fi

echo "Renewing client connection..."
echo -ne "AUTHENTICATE \"ruhf4uh1fh4203fhwqhrqf3ihuq\"\r\nSIGNAL NEWNYM\r\n" | nc -w 1 127.0.0.1 9051 > /dev/null

echo -ne "New IP: "
NEW_IP="$(echo -ne "GET /text HTTP/1.1\r\nHost: wtfismyip.com\r\nConnection: close\r\n\r\n" | nc wtfismyip.com 80 | tail -n -1)"
echo "$NEW_IP"

if [[ "$OLD_IP" != "$NEW_IP" ]]; then
        echo "IP changed correctly"
else
	echo "ERROR changing IP!"
fi
