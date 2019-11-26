#!/bin/bash
apt-get -y install binutils upx
strip --strip-all "$1"
upx --ultra-brute --overlay=strip -o "$1.stripped" "$1"
