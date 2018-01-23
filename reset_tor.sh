#!/bin/bash

# Reset all tor data and stop tor service

service tor stop
sleep 1
rm -rf /var/lib/tor/*
