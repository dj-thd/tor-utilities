#!/bin/bash

# Dirty bash script to do a port scan through routed Tor
# based on socket response time

# Normal scan tools wont work and report all ports as open because of the
# inner workings of transparent routing through Tor

FIFO="$(mktemp)"
rm "$FIFO"
mkfifo "$FIFO"

IP="$1"

function scan() {
	IP="$1"
	PORT="$2"
	BEGIN="$(date +"%s")"
	if [[ "$(timeout 5 nc -w 2 -q 2 -n "$IP" "$PORT" -vv 2>&1 <>"$FIFO" | grep 'open')" != "" ]]; then
		END="$(date +"%s")"
		if [ "$(expr $END - $BEGIN)" -gt 3 ]; then
			echo "[+] $IP $PORT"
		fi
	fi
}

for PORT in `seq 1 65535`; do
	while [ "$(jobs | wc -l)" -gt 128 ]; do
		wait
	done
	scan "$IP" "$PORT" &
done

while [ "$(jobs | wc -l)" -gt 0 ]; do
	wait
done

rm "$FIFO"
