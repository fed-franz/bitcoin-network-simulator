#!/bin/bash

#Create btcnet - maybe multiple ones
echo "Creating 'btcnet' network"
docker network create --internal --subnet 10.1.0.0/16 btcnet

#Start DNS
echo "Starting Bitcoin DNS seeder"
docker run -d --network btcnet --ip 10.1.1.2 fedfranz/bitcoinlocal-seeder:bind

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
