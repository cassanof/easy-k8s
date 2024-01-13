# easy-k8s

Setting up default k8s is always a PITA - this makes it easier

Run `./setup.sh` **as root AFTER** you have installed docker, containerd, kubeadm, kubelet and kubectl
using whatever method you prefer.

You can then run `./setup_cluster.sh` on the master node to setup the cluster with Calico networking.
**This assumes you have run `./setup.sh` on the master node as well.**
