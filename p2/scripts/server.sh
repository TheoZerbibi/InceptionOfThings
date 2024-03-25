#!/bin/sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Path: p2/scripts/server.sh										#
# Author: Theo ZERIBI												#
# Date: 2024-03-14													#
# Description: This script is used for setup the Server Machine.	#
# It will install K3s and configure it for a server machine.		#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo LC_ALL=C >> /etc/environment

if [ -z "$1" ] || [ -z "$2" ] ; then
	echo "Arguments are missing"
	exit 1
fi

MANIFEST_TMP_DIR=$1
SERVER_IP=$2
LOWER_HOSTNAME=`echo "$(hostname)" | sed 's/./\L&/g'`
echo "The server IP is: ${SERVER_IP}"
echo "The server hostname is: $(hostname) [$LOWER_HOSTNAME]"

if [ ! -d ${MANIFEST_TMP_DIR} ] || [ -z "$(ls -A $MANIFEST_TMP_DIR)" ]; then
	echo "The path provided is not a directory or is empty"
	exit 1
fi

# Add current node to the /etc/hosts file
echo "127.0.1.1  $(hostname)" >> /etc/hosts

# Install curl
apt-get update && apt-get install -y curl

# Install K3s and configure it for a server machine
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --cluster-init --tls-san $(hostname) --bind-address=${SERVER_IP} --advertise-address=${SERVER_IP} --node-ip=${SERVER_IP}" K3S_KUBECONFIG_MODE="644" sh -

# Set the KUBECONFIG environment variable
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Wait for the node to be ready
kubectl wait --for=condition=Ready node/${LOWER_HOSTNAME} --timeout=5m

# Apply the manifest files
kubectl apply -f ${MANIFEST_TMP_DIR}

# Wait for the deployment and pods to be available
kubectl wait deployment --all --for=condition=Available=True -n default --timeout=10m
kubectl wait pod --all --for=condition=Ready -n default --timeout=10m
