#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Copyright 2022 Authors of auto-policy-discovery

# create a single-node K3s cluster
#curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.20.8+k3s1" K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--disable=traefik" sh -
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--disable=traefik" sh -
[[ $? != 0 ]] && echo "Failed to install k3s" && exit 1

KUBEDIR=$HOME/.kube
KUBECONFIG=$KUBEDIR/config

[[ ! -d $KUBEDIR ]] && mkdir $HOME/.kube/
if [ -f $KUBECONFIG ]; then
	KUBECONFIGBKP=$KUBEDIR/config.backup
	echo "Found $KUBECONFIG already in place ... backing it up to $KUBECONFIGBKP"
	cp $KUBECONFIG $KUBECONFIGBKP
fi

cp /etc/rancher/k3s/k3s.yaml $KUBEDIR/config 

for (( ; ; ))
do
	status=$(kubectl get pods -A -o jsonpath={.items[*].status.phase})
	[[ $(echo $status | grep -v Running | wc -l) -eq 0 ]] && break
	echo "wait for initialization"
	sleep 1
done

kubectl get pods -A
