#!/bin/bash
# Original scripts taken & modified from https://docs.j7k6.org/tor-static-build/

# This script will download latest versions of Tor and dependency libraries,
# then compile it as static binary

# Tested with Kali Linux rolling x64 (updated as Jan 2018)
# May work on other systems, not tested

# https://github.com/dj-thd <dj.thd@hotmail.com>

ZLIB_VERSION=1.2.11
LIBEVENT_VERSION=2.1.8-stable
OPENSSL_VERSION=1.0.2n
TOR_VERSION=0.3.2.9

apt-get -y install build-essential gcc g++ binutils tar curl

# Dirty functions but working

function getLatestZlib() {
	echo Getting latest zlib version... >&2
	curl -fsSL https://zlib.net | egrep -o '<FONT SIZE="\+2"><B>\s*zlib\s*[0-9]+\.[0-9]+\.[0-9]+\s*</B></FONT>' | egrep -o '[0-9]+\.[0-9]+\.[0-9]+'
}

function getLatestLibEvent() {
	echo Getting latest libevent version... >&2
	curl -fsSL https://github.com/libevent/libevent/releases/latest | grep 'libevent/libevent/releases/tag/' | grep 'release-' | egrep -o 'release-[^"''&]+' | head -n1 | cut -b9-
}

function getLatestOpenSSL() {
	echo Getting latest openssl version... >&2
	curl -fsSL https://www.openssl.org/source | grep td | grep '<a' | grep -m 1 openssl- | egrep -m 1 -o 'openssl-[^"''&]+?\.tar\.gz' | tail -n1 | cut -b9- | egrep -o '[^\.]+\.[^\.]+\.[^\.]+'
}

function getLatestTor() {
	echo Getting latest tor version... >&2
	curl -fsSL https://dist.torproject.org/ | egrep -o 'tor-[0-9\.]+\.tar.gz' | sort | tail -n1 | egrep -o '[0-9\.]+' | sed 's/[^0-9]$//g'
}

# Get latest versions

LATEST_ZLIB="$(getLatestZlib)"
LATEST_LIBEVENT="$(getLatestLibEvent)"
LATEST_OPENSSL="$(getLatestOpenSSL)"
LATEST_TOR="$(getLatestTor)"

if [ -z "$LATEST_ZLIB" ]; then
	echo "WARNING: Could not get latest zlib version"
fi
if [ -z "$LATEST_LIBEVENT" ]; then
	echo "WARNING: Could not get latest libevent version"
fi
if [ -z "$LATEST_OPENSSL" ]; then
	echo "WARNING: Could not get latest openssl version"
fi
if [ -z "$LATEST_TOR" ]; then
	echo "WARNING: Could not get latest tor version"
fi

# Check if the script version is different for each package (TODO: write a function to do this instead of copypasted code)

if [ "$LATEST_ZLIB" != "$ZLIB_VERSION" ] && [ -n "$LATEST_ZLIB" ]; then
	echo "Script zlib version is $ZLIB_VERSION, Latest zlib version is $LATEST_ZLIB"
	read -p "Do you want to use the latest version? [y/n] " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		ZLIB_VERSION="$LATEST_ZLIB"
	fi
fi

if [ "$LATEST_LIBEVENT" != "$LIBEVENT_VERSION" ] && [ -n "$LATEST_LIBEVENT" ]; then
	echo "Script libevent version is $LIBEVENT_VERSION, Latest libevent version is $LATEST_LIBEVENT"
	read -p "Do you want to use the latest version? [y/n] " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		LIBEVENT_VERSION="$LATEST_LIBEVENT"
	fi
fi

if [ "$LATEST_OPENSSL" != "$OPENSSL_VERSION" ] && [ -n "$LATEST_OPENSSL" ]; then
	echo "Script openssl version is $OPENSSL_VERSION, Latest openssl version is $LATEST_OPENSSL"
	read -p "Do you want to use the latest version? [y/n] " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		OPENSSL_VERSION="$LATEST_OPENSSL"
	fi
fi

if [ "$LATEST_TOR" != "$TOR_VERSION" ] && [ -n "$LATEST_TOR" ]; then
	echo "Script tor version is $TOR_VERSION, Latest tor version is $LATEST_TOR"
	read -p "Do you want to use the latest version? [y/n] " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		TOR_VERSION="$LATEST_TOR"
	fi
fi

ROOTDIR="$(pwd)"

# ZLIB download and compile

# Ask user to not overwrite zlib if existing (TODO: write a function to do this instead of copypasted code)

if [ -d zlib ]; then
	echo "zlib folder has been detected, do you want to overwrite and recompile"
	read -p "with new zlib sources? [y/n] " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		rm -rf zlib
	else
		SKIP_ZLIB=1
	fi
fi

# Download and compile zlib

if [ -z "$SKIP_ZLIB" ]; then
	echo Downloading and compiling zlib...
	mkdir zlib && cd zlib && curl -fsSL https://zlib.net/zlib-$ZLIB_VERSION.tar.gz | tar xzvf -
	cd zlib-$ZLIB_VERSION
	./configure --prefix=$PWD/install
	make -j$(nproc)
	make install
	cd "$ROOTDIR"
fi


# LIBEVENT download and compile

# Ask user to not overwrite libevent if existing (TODO: write a function to do this instead of copypasted code)

if [ -d libevent ]; then
	echo "libevent folder has been detected, do you want to overwrite and recompile"
	read -p "with new libevent sources? [y/n] " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		rm -rf libevent
	else
		SKIP_LIBEVENT=1
	fi
fi

# Download and compile libevent

if [ -z "$SKIP_LIBEVENT" ]; then
	echo Downloading and compiling libevent...
	mkdir libevent && cd libevent && curl -fsSL https://github.com/libevent/libevent/releases/download/release-$LIBEVENT_VERSION/libevent-$LIBEVENT_VERSION.tar.gz | tar xzvf -
	cd libevent-$LIBEVENT_VERSION
	./configure --prefix=$PWD/install --disable-shared --enable-static --with-pic
	make -j$(nproc)
	make install
	cd "$ROOTDIR"
fi


# LIBEVENT download and compile

# Ask user to not overwrite libevent if existing (TODO: write a function to do this instead of copypasted code)

if [ -d openssl ]; then
	echo "openssl folder has been detected, do you want to overwrite and recompile"
	read -p "with new openssl sources? [y/n] " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		rm -rf openssl
	else
		SKIP_OPENSSL=1
	fi
fi

# Download and compile openssl

if [ -z "$SKIP_OPENSSL" ]; then
	echo Downloading and compiling openssl...
	mkdir openssl && cd openssl && curl -fsSL https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz | tar xzvf -
	cd openssl-$OPENSSL_VERSION
	./config --prefix=$PWD/install no-shared no-dso
	make -j$(nproc)
	make install
	cd "$ROOTDIR"
fi


# LIBEVENT download and compile

# Ask user to not overwrite libevent if existing (TODO: write a function to do this instead of copypasted code)

if [ -d tor ]; then
	echo "tor folder has been detected, do you want to overwrite and recompile"
	read -p "with new tor sources? [y/n] " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		rm -rf tor
	else
		SKIP_TOR=1
	fi
fi

# Download and compile tor

if [ -z "$SKIP_TOR" ]; then
	echo Downloading and compiling tor...
	mkdir tor && cd tor && curl -fsSL https://dist.torproject.org/tor-$TOR_VERSION.tar.gz | tar xzvf -
	cd tor-$TOR_VERSION
	./configure --prefix=$PWD/install --enable-static-tor \
		--with-libevent-dir=$PWD/../../libevent/libevent-$LIBEVENT_VERSION/install \
		--with-openssl-dir=$PWD/../../openssl/openssl-$OPENSSL_VERSION/install \
		--with-zlib-dir=$PWD/../../zlib/zlib-$ZLIB_VERSION/install
	make -j$(nproc)
	make install
	cd "$ROOTDIR"
fi

echo Done.
echo Your Tor static binaries are located at tor/tor-$TOR_VERSION/install/bin


