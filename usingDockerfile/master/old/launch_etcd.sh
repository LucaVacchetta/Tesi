#!/usr/bin/env bash
set -x

pid=0

# SIGTERM-handler
term_handler() {
  if [ $pid -ne 0 ]; then
    rm -f /mnt/clusterDiscoveryID
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; term_handler' SIGTERM

# run application
# Definition of some useful environment variables
export LOCALIP=`ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`
export NAME_MASTER=master-$LOCALIP

# Creation of new etcd cluster
curl -w "\n" 'https://discovery.etcd.io/new?size=1' > /mnt/clusterDiscoveryID

#trap "rm -f /mnt/clusterDiscoveryID" SIGTERM

# Add the jmeter master to the cluster
etcd --name $NAME_MASTER --initial-advertise-peer-urls http://$LOCALIP:2380 --listen-peer-urls http://$LOCALIP:2380 --listen-client-urls http://$LOCALIP:2379,http://127.0.0.1:2379 --advertise-client-urls http://$LOCALIP:2379 --discovery `cat /mnt/clusterDiscoveryID` &


# wait forever
while true
do
  exec /bin/sh --nodaemon
  pid="$!"
  wait ${!}
done
# Definition of some useful environment variables
#export LOCALIP=`ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`
#export NAME_MASTER=master-$LOCALIP

# Creation of new etcd cluster
#curl -w "\n" 'https://discovery.etcd.io/new?size=1' > /mnt/clusterDiscoveryID

#trap "rm -f /mnt/clusterDiscoveryID" SIGTERM

# Add the jmeter master to the cluster
#etcd --name $NAME_MASTER --initial-advertise-peer-urls http://$LOCALIP:2380 --listen-peer-urls http://$LOCALIP:2380 --listen-client-urls http://$LOCALIP:2379,http://127.0.0.1:2379 --advertise-client-urls http://$LOCALIP:2379 --discovery `cat /mnt/clusterDiscoveryID` &

#sleep 5

#trap "rm -f /mnt/clusterDiscoveryID" SIGTERM

#/bin/bash

#trap "rm -f /mnt/clusterDiscoveryID" SIGTERM
