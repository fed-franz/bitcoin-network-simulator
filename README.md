# local-btc-net
It allows to locally simulate a Bitcoin network with Docker.
Currently working with Testnet only.

1. Create an isolated network:
docker network create --internal --subnet 10.1.1.0/24 btcnet

2. Run the BIND dns:
docker run -it --network btcnet fedfranz/bitcoinlocal-seeder:bind
# The DNS server will be at IP 10.1.1.2

3. Run nodes:
docker run -it --network btcnet --dns=10.1.1.2
