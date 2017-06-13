#!/bin/bash

#slave setup

# ip=$(/sbin/ip -o -4 addr list ens192 | awk '{print $4}' | cut -d/ -f1) questo da solo l'indirizzo IP sulla scheda di rete ens192
export IPADDRESS=$(hostname -I)		# TODO da troppi indirizzi, CONTROLLARE
yum -y install --enablerepo=virt7-docker-common-release kubernetes etcd flannel

#Modify file config with right parameters
cat <<EOF > /etc/kubernetes/config 
###
# kubernetes system config
#
# The following values are used to configure various aspects of all
# kubernetes services, including
#
#   kube-apiserver.service
#   kube-controller-manager.service
#   kube-scheduler.service
#   kubelet.service
#   kube-proxy.service

# logging to stderr means we get it in the systemd journal
KUBE_LOGTOSTDERR="--logtostderr=true"

# journal message level, 0 is debug
KUBE_LOG_LEVEL="--v=0"

# Should this cluster be allowed to run privileged docker containers
KUBE_ALLOW_PRIV="--allow-privileged=false"

# How the replication controller and scheduler find the kube-apiserver
KUBE_MASTER="--master=http://$1:8080"
EOF

#configura SELinux con una politica permissiva
setenforce 0

#disabilita il firewall
systemctl disable iptables-services firewalld
systemctl stop iptables-services firewalld

cat << EOF > /etc/kubernetes/kubelet
###
# kubernetes kubelet (minion) config

# The address for the info server to serve on
KUBELET_ADDRESS="--address=0.0.0.0"

# The port for the info server to serve on
KUBELET_PORT="--port=10250"

# You may leave this blank to use the actual hostname
# Check the node number!
KUBELET_HOSTNAME="--hostname-override=$IPADDRESS"

# Location of the api-server
KUBELET_API_SERVER="--api-servers=http://$1:8080"

# pod infrastructure container
# KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=registry.access.redhat.com/rhel7/pod-infrastructure:latest"

# Add your own!
KUBELET_ARGS=""
EOF

cat << EOF > /etc/sysconfig/flanneld
# Flanneld configuration options

FLANNEL_ETCD="http://$1:2379"

# etcd url location.  Point this to the server where etcd runs
FLANNEL_ETCD_ENDPOINTS="http://$1:2379"

# etcd config key.  This is the configuration key that flannel queries
# For address range assignment
FLANNEL_ETCD_PREFIX="/kube-centos/network"

# Any additional options that you want to pass
FLANNEL_OPTIONS=""
EOF

for SERVICES in kube-proxy kubelet flanneld docker; do
    systemctl restart $SERVICES
    systemctl enable $SERVICES
    systemctl status $SERVICES
done

kubectl config set-cluster default-cluster --server=http://$1:8080
kubectl config set-context default-context --cluster=default-cluster --user=default-admin
kubectl config use-context default-context
