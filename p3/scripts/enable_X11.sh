#!/bin/sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Path: p3/scripts/enable_X11.sh									#
# Author: Theo ZERIBI												#
# Date: 2024-03-10													#
# Description: This script for enabling X11 forwarding on Vagrant	#
# Virtual Machine.													#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get --with-new-pkgs upgrade -y
apt-get install -y xauth x11-apps net-tools
sed -i 's/[#]*X11UseLocalhost[ ]*[a-z]*/X11UseLocalhost no/' /etc/ssh/sshd_config
sed -i 's/[#]*AllowAgentForwarding[ ]*[a-z]*/AllowAgentForwarding yes/' /etc/ssh/sshd_config
systemctl reload ssh && systemctl restart ssh
