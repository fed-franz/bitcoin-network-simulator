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
  echo "Creating 'btcnet' network"
  docker network create --internal --subnet 10.1.0.0/16 btcnet
fi
exit
#Start DNS
echo "Starting Bitcoin DNS seeder"
docker run -d --network btcnet --ip 10.1.1.2 --name="btc-dns-seeder" fedfranz/bitcoinlocal-seeder:bind

#Start nodes
  for i in {1..100}
  do
      echo "Starting Bitcoin node container"
      docker run -d --network btcnet --dns=10.1.1.2 --name="btc-$i" fedfranz/bitcoinlocal:0.12.0-testnet
  done

#Start miners
  for i in {1..100}
  do
      echo "Starting Bitcoin node container"
      docker run -d --network btcnet --dns=10.1.1.2 --name="btc-miner-$i" fedfranz/bitcoinlocal:0.12.0-testnet-miner
  done
