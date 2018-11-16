#!/bin/bash

### UTILS ###
function check_exit () {
    # "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "ERROR: $1 failed ($status)" >&2
        exit $status
    fi
}

### ENVIRONMENT ###
numnodes=100
numminers=10

DNS_DOCK="fedfranz/btcnet-dns"
DNS_DOCK_NAME="btcdns"
DNS_IP="10.1.1.2"
BTCNET=btcnet
BTC_NODE_DOCK="fedfranz/bitcoinlocal:0.12.0-testnet"
BTC_MINER_DOCK="fedfranz/bitcoinlocal:0.12.0-testnet-miner"

#ARGS
if [ ! -z "$1" ]
  then numnodes=$1
fi
if [ ! -z "$2" ]
  then numminers=$2
fi

### BEGINNING OF PROGRAM ###
echo "Starting $numnodes nodes and $numminers miners"


#Create btcnet - maybe multiple ones
if docker network list | grep -q $BTCNET
then
  echo "$BTCNET already exists; skipping..."
else
  #TODO Create multiple networks
  #TODO Take nun of subnets as a parameter
  echo "Creating $BTCNET network"
  docker network create --internal --subnet 10.1.0.0/16 $BTCNET
  check_exit "docker network create"
fi


#Update docker images
#TODO Take list of images as a parameter
docker pull $BTC_NODE_DOCK
docker pull $BTC_MINER_DOCK
docker pull $DNS_DOCK


#Start DNS
#TODO automatically add first N nodes to the config file, after starting the containers (alternatively, just add the first 10 IPs to the zone file)
if docker ps | grep -q $DNS_DOCK_NAME
then
  echo "DNS seeder container already exists; skipping..."
else
  echo "Starting Bitcoin DNS seeder"
  docker run -d --network $BTCNET --ip $DNS_IP --name=$DNS_DOCK_NAME $DNS_DOCK
  check_exit "docker run $DNS_DOCK"
fi

#TODO Start fixed nodes with specific IPs (those returned by the DNS)
#Start miners
  for i in $(seq 1 $numminers)
  do
      echo "Starting Bitcoin miner container"
      docker run -d --network $BTCNET --dns=$DNS_IP $BTC_MINER_DOCK
      check_exit "docker run $BTC_MINER_DOCK"
  done

#Start nodes
  for i in $(seq 1 $numnodes)
  do
      #TODO For each container in the list
      echo "Starting Bitcoin node container"
      docker run -d --network $BTCNET --dns=$DNS_IP $BTC_NODE_DOCK
      check_exit "docker run $BTC_NODE_DOCK"
  done

  #TODO loop nodes on/off
