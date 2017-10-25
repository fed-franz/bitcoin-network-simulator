# btc-box docker image
# bitcoin-version=0.15

ENV datadir=btc-data
ENV btcnet=testnet3
ENV bindir=btc-bin

# Debian
FROM debian:latest

RUN apt-get update
RUN apt-get install --yes net-tools dnsutils tcpdump
# dnsutils -> nslookup
# netcat   -> nc

# set working directory
COPY ../$bindir /root/$bindir
COPY ../$datadir /root/$datadir

RUN ln -s /root/$bindir/* /usr/local/bin

ENV btc-cli=bitcoin-cli -datadir=$datadir
RUN echo "alias btc-cli='$btc-cli'" >> ~/.bashrc \
 && echo "alias getpeers='$btc-cli getpeerinfo'" >> ~/.bashrc \
 && echo "alias getblockcount='$btc-cli getblockcount'" >> ~/.bashrc \
 && echo "alias getdebuglog='cat $datadir/$btcnet/debug.log'" >> ~/.bashrc \
 && echo "alias getpeersaddr='getpeers | grep addr'" >> ~/.bashrc \
 && echo "alias btcstart='bitcoind -datadir=$datadir -onlynet=ipv4 -debug -logips -daemon'" >> ~/.bashrc \
 && echo "alias btcstop='$btc-cli stop'" >> ~/.bashrc

WORKDIR /root/

# Expose Bitcoin ports
EXPOSE 18333 18332

ENTRYPOINT bitcoind -datadir=$datadir -testnet -onlynet=ipv4 -debug -logips -daemon && /bin/bash
