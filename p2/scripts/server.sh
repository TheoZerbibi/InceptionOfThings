#!/bin/sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Path: p1/scripts/server.sh										#
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

# Move the manifests to the K3s server directory
mv ${MANIFEST_TMP_DIR}/* /var/lib/rancher/k3s/server/manifests/

# Set the KUBECONFIG environment variable
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Wait for the node to be ready and label it as a master node with NoSchedule taint
kubectl wait --for=condition=Ready node/${LOWER_HOSTNAME} --timeout=5m
kubectl label node ${LOWER_HOSTNAME} node-role.kubernetes.io/master=true 