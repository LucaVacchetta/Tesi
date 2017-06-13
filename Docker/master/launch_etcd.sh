#!/bin/bash

# Definition of some useful environment variables
export LOCALIP=`ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`
export NAME_MASTER=master-$LOCALIP

# Creation of new etcd cluster
curl -w "\n" 'https://discovery.etcd.io/new?size=1' > /mnt/clusterDiscoveryID

# Add the jmeter master to the cluster
etcd --name $NAME_MASTER --initial-advertise-peer-urls http://$LOCALIP:2380 --listen-peer-urls http://$LOCALIP:2380 --listen-client-urls http://$LOCALIP:2379,http://127.0.0.1:2379 --advertise-client-urls http://$LOCALIP:2379 --discovery `cat /mnt/clusterDiscoveryID` &

# Launch bash in order to have an interactive shell on master
exec bash --init-file <(echo "trap \"rm -f /mnt/clusterDiscoveryID\" SIGTERM EXIT; alias jmeter='/run/jmeter_to_all_slaves.sh'")
