#!/bin/bash

# Reset all the data in the firefox user profile
# (destroy all trackeable data like cookies, storage, etc)

killall firefox
rm -rf ~/.mozilla/firefox
