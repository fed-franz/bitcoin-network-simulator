#!/bin/bash

numnodes=100
numminers=10

if [ ! -z "$1" ]
  then numnodes=$1
fi
if [ ! -z "$2" ]
  then numminers=$2
fi

echo "Starting $numnodes nodes and $numminers miners"

#Create btcnet - maybe multiple ones
if docker network list | grep -q 'btcnet'
then
  echo "'btcnet' already exists; skipping..."
else
  #TODO Create multiple networks
  #TODO Take nun of subnets as a parameter
  echo "Creating 'btcnet' network"
  docker network create --internal --subnet 10.1.0.0/16 btcnet
fi

#Update docker images
#TODO Take list of images as a parameter
docker pull fedfranz/bitcoinlocal-seeder:bind
docker pull fedfranz/bitcoinlocal-seeder:bind-it
docker pull fedfranz/bitcoinlocal:0.12.0-testnet
docker pull fedfranz/bitcoinlocal:0.12.0-testnet-it
docker pull fedfranz/bitcoinlocal:0.12.0-testnet-miner

#Start DNS
#TODO mv to docker-bind container; automatically add first N nodes to the config file, after starting the containers
if docker container list | grep -q 'btc-dns-seeder'
then
  echo "DNS seeder container already exists; skipping..."
else
  echo "Starting Bitcoin DNS seeder"
  docker run -d --network btcnet --ip 10.1.1.2 --name="btc-dns-seeder" fedfranz/bitcoinlocal-seeder:bind
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to start DNS container - exiting..." && exit $?
  fi
fi

#TODO Start fixed nodes with specific IPs (those returned by the DNS)
#Start miners
  for i in $(seq 1 $numminers)
  do
      echo "Starting Bitcoin miner container"
      docker run -d --network btcnet --dns=10.1.1.2 fedfranz/bitcoinlocal:0.12.0-testnet-miner
  done

#Start nodes
  for i in $(seq 1 $numnodes)
  do
      #TODO For each container in the list
      echo "Starting Bitcoin node container"
      docker run -d --network btcnet --dns=10.1.1.2 fedfranz/bitcoinlocal:0.12.0-testnet
  done

  #TODO loop nodes on/off
