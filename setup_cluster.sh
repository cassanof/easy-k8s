#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

echo "Running kubeadm init -- output will be saved at kubeadm-init.txt"
kubeadm init --pod-network-cidr=192.168.0.0/16 | tee kubeadm-init.txt
OUT=$?
if [ $OUT -ne 0 ];then
    echo "kubeadm init failed"
    exit 1
fi

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml

echo "Waiting for calico pods to be ready"
while [[ true ]]; do
    WCS=$(kubectl get pods -n calico-system | grep "Running" | wc -l)
    # needs to be 4
    if [ $WCS -eq 4 ]; then
        printf "\n"
        break
    fi
    printf "."
    sleep 3
done

kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl taint nodes --all node-role.kubernetes.io/master-
