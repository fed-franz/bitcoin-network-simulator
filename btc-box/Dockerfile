# btc-box docker image
# bitcoin-version=0.15

ENV datadir=btc-data
ENV btcnet=regtest
#ENV btcnet=testnet3
ENV bindir=btc-bin

# Debian
FROM debian:latest

RUN apt-get update
RUN apt-get install --yes net-tools dnsutils tcpdump
# dnsutils -> nslookup
# netcat   -> nc

# set working directory
COPY ./btc-bin /root/btc-bin

RUN ln -s /root/btc-bin/* /usr/local/bin
RUN echo "alias getpeers='bitcoin-cli -datadir=$datadir getpeerinfo'" >> ~/.bashrc \
 && echo "alias getblockcount='bitcoin-cli -datadir=$datadir getblockcount'" >> ~/.bashrc \
 && echo "alias getdebuglog='cat $datadir/$btcnet/debug.log'" >> ~/.bashrc \
 && echo "alias getpeersaddr='getpeers | grep addr'" >> ~/.bashrc \
 && echo "alias btcstop='bitcoin-cli -datadir=$datadir stop'" >> ~/.bashrc
#TODO: getmyaddr

WORKDIR /root/

# Expose Bitcoin ports
EXPOSE 18444 18443
#btc: 8333 8332(rpc)
#testnet: 18333 18332
#regtest: 18444 18443

ENTRYPOINT bitcoind -datadir=$datadir -onlynet=ipv4 -debug -logips -daemon && /bin/bash
#-forcednsseed
#-dns -seednode="seed.seeder.btc"
#-dnsseed
