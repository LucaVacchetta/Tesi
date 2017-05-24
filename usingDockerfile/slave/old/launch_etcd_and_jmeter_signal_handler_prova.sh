#!/usr/bin/env bash
set -x
pid=0

#Sig TERM handler
term_handler(){
  if [ $pid -ne 0 ]; then
    etcdctl rmdir $LOCALIP
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; term_handler' SIGTERM

#Definition of some useful environment variables
export LOCALIP=`ifconfig eth0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`
export NAME_SLAVE=slave-$LOCALIP

#Add this node to etcd cluster
etcd --name $NAME_SLAVE --initial-advertise-peer-urls http://$LOCALIP:2380 --listen-peer-urls http://$LOCALIP:2380 --listen-client-urls http://$LOCALIP:2379,http://127.0.0.1:2379 --advertise-client-urls http://$LOCALIP:2379 --discovery https://discovery.etcd.io/5398923a9d6ab254a6a387218c2e1c38 &

#Sleep useful for synchronization
sleep 3
etcdctl mk $LOCALIP OK
$JMETER_HOME/bin/jmeter-server -Dserver.rmi.localport=50000 -Dserver_port=1099 &

pid="$!"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
