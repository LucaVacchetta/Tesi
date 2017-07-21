#!/bin/bash

MASTER_IP_SOFTLAYER=$1
WORKER_IP_SOFTLAYER=$2
WORKER_IP_AWS=$3

# login in master node console
ssh -o StrictHostKeyChecking=no root@$MASTER_IP_SOFTLAYER

# add labels to worker nodes
kubectl label nodes $WORKER_IP_SOFTLAYER cloud-provider=Softlayer
kubectl label nodes $WORKER_IP_AWS cloud-provider=AWS


# now replace the endpoint of the tunnel with aws server because probably amazon use a reverse proxy,
# so the endpoint of the tunnel is with a private IP
etcdctl ls kube-centos/network/subnets > output_etcd

for i in $(seq 1 4); do
  awk 'BEGIN{FS="/"} NR=='$i' {print $5}' output_etcd >> output_filtrato
done

for i in $(seq 1 4); do
  subnet=`awk 'NR=='$i' {print $0}' output_filtrato`
  etcdctl get kube-centos/network/subnets/$subnet > output_etcdctl
  publicIP=`awk -F "\"" '{print $4}' output_etcdctl`
#  echo $publicIP
  if [ "$publicIP" = "$MASTER_IP_SOFTLAYER" ] && [ "$publicIP" = "$WORKER_IP_SOFTLAYER" ]
  then
    firstPart=`awk -F \${publicIP} '{print $1}' output_etcdctl`
#    echo $firstPart
    secondPart=`awk -F \${publicIP} '{print $2}' output_etcdctl`
#    echo $firstPart$WORKER_IP_AWS$secondPart
    entryUpdated=$firstPart$WORKER_IP_AWS$secondPart

    # alla stringa entryUpdated va aggiunto il \ davanti ad ogni " prima di poterla settare nel etcd DB
    echo $entryUpdated > newEntry
    sed -i 's/\"/\\\"/g' newEntry
    etcdctl set kube-centos/network/subnets/$subnet "`cat newEntry`"
    echo $publicIP
  else
    echo "ok"
  fi
done

rm -f output_filtrato
rm -f output_etcd

# now it need to restart flanneld service on all servers
