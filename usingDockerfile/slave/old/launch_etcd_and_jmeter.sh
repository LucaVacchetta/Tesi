#!/bin/bash
export LOCALIP=`ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`
export NAME_SLAVE=slave-$LOCALIP
etcd --name $NAME_SLAVE --initial-advertise-peer-urls http://$LOCALIP:2380 --listen-peer-urls http://$LOCALIP:2380 --listen-client-urls http://$LOCALIP:2379,http://127.0.0.1:2379 --advertise-client-urls http://$LOCALIP:2379 --discovery `cat /mnt/clusterDiscoveryID` &
sleep 3
trap "etcdctl rmdir $LOCALIP" EXIT
etcdctl mk $LOCALIP OK
$JMETER_HOME/bin/jmeter-server -Dserver.rmi.localport=50000 -Dserver_port=1099 &
/bin/bash
