#!/bin/bash
export LOCALIP=`ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`;
export NAME_MASTER=master-$LOCALIP;
echo $LOCALIP;
echo $NAME_MASTER;
alias jmeter='/run/jmeter_to_all_slaves.sh';
alias;
curl -w "\n" 'https://discovery.etcd.io/new?size=1' > /mnt/clusterDiscoveryID;
etcd --name $NAME_MASTER --initial-advertise-peer-urls http://$LOCALIP:2380 --listen-peer-urls http://$LOCALIP:2380 --listen-client-urls http://$LOCALIP:2379,http://127.0.0.1:2379 --advertise-client-urls http://$LOCALIP:2379 --discovery `cat /mnt/clusterDiscoveryID` & \

