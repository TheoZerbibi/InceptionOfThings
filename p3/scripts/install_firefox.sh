#!/bin/sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Path: p3/scripts/install_firefox.sh								#
# Author: Theo ZERIBI												#
# Date: 2024-03-10													#
# Description: This script will install and configure Firefox on 	#
# Vagrant Virtual Machine.											#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Check if the script is run as root
if [ `id -u` -ne 0 ]
	then echo Please run this script as root or using sudo!
	exit
fi

# Add Mozilla signing key
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

# Add Mozilla repository
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

# Set the priority to 1000
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla 

# Update and install Firefox
sudo apt-get update && sudo apt-get install firefox -y
