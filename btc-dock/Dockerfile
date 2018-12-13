# Bitcoin Node

FROM ubuntu:latest

#TODO: accept URL and download binaries
# ARG binuri=https://github.com/frz-dev/bitcoin-local/raw/0.12.0-local/bin #TODO accept both local or url

# Local ENV
ENV startscript=start-node.sh \
    runscript=btc-node-run.sh
ENV datadir=./btc/data
ENV bindir=./btc/bin

# Install utilities
RUN apt-get update
# net-tools -> ifconfig
# dnsutils -> nslookup
RUN apt-get install --yes net-tools dnsutils wget bc

# Copy Bitcoin files
WORKDIR /root/
COPY $datadir/bitcoin.conf /root/.bitcoin/bitcoin.conf
COPY $bindir/bitcoind $bindir/bitcoin-cli /usr/local/bin/
RUN chmod a+x /usr/local/bin/bitcoind /usr/local/bin/bitcoin-cli

COPY ./$startscript ./
COPY ./$runscript ./
RUN chmod a+x $startscript $runscript

# Expose Bitcoin ports
#Mainnet: 8333, 8332 (RPC)
#Testnet: 18333, 18332 (RPC)
#Regtest: 18444, 18443 (RPC)
EXPOSE 8333 8332 18333 18332 18443 18444

# Then run bitcoin
ENTRYPOINT ["./start-node.sh"]
#TODO Arguments passed via 'docker run' will be bitcoind arguments
#Argument 'btcnet'; default is "" (mainnet).
#To run node in testnet or regtest mode, use 'docker run btcnode $btcnet'
CMD [""]
