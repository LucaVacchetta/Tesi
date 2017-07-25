#!/bin/bash

MASTER_IP_SOFTLAYER=$1
WORKER_IP_SOFTLAYER=$2
WORKER_IP_AWS=$3

# login in master node console
ssh -o StrictHostKeyChecking=no root@$MASTER_IP_SOFTLAYER "/run/script-on-master.sh $MASTER_IP_SOFTLAYER $WORKER_IP_SOFTLAYER $WORKER_IP_AWS"

#log into worker softlayer node
ssh -o StrictHostKeyChecking=no root@$WORKER_IP_SOFTLAYER 'systemctl restart flanneld'
