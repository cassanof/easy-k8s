#!/bin/bash

# quit if not root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system

# copy daemon.json to /etc/docker/daemon.json
cp ./daemon.json /etc/docker/daemon.json

# copy containerd config.toml to /etc/containerd/config.toml
cp ./config.toml /etc/containerd/config.toml

# restart stuff
systemctl daemon-reload
systemctl restart docker
systemctl restart containerd

# enable kubelet
systemctl enable --now kubelet.service

echo "**********"
echo "Done! if you are setting up a cluster on the master node, run ./setup_cluster.sh next"
