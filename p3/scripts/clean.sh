#!/bin/sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Path: p3/scripts/clean.sh											#
# Author: Theo ZERIBI												#
# Date: 2024-03-10													#
# Description: This script will clean up the K3D installation on 	#
# Vagrant Virtual Machine.											#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Check if the script is run as root
if [ `id -u` -ne 0 ]
	then echo Please run this script as root or using sudo!
	exit
fi

# Clean up the K3D installation
kubectl delete all --all --namespace argocd
kubectl delete all --all --namespace dev
kubectl delete all --all --namespace default
k3d cluster delete --all
