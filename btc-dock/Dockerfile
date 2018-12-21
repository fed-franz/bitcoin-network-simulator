# Bitcoin Node

FROM ubuntu:latest

#TODO: accept URL and download binaries
# ARG binuri=https://github.com/frz-dev/bitcoin-local/raw/0.12.0-local/bin #TODO accept both local or url

# Local ENV
ENV startscript=init.sh \
    runscript=btc-node-run.sh \
    btcscript=btc-node-activity.sh
ENV datadir=./btc/data
ENV bindir=./btc/bin

# Install utilities
# net-tools -> ifconfig ; dnsutils -> nslookup
RUN apt-get update
RUN apt-get install --yes net-tools dnsutils wget bc

# Copy Bitcoin files
WORKDIR /root/
COPY $datadir/bitcoin.conf /root/.bitcoin/bitcoin.conf
COPY $bindir/bitcoind $bindir/bitcoin-cli /usr/local/bin/
RUN chmod a+x /usr/local/bin/bitcoind /usr/local/bin/bitcoin-cli

COPY scripts ./
RUN chmod a+x ./*.sh

# Expose Bitcoin ports
EXPOSE 8333 8332 18333 18332 18443 18444

# Then run bitcoin
ENTRYPOINT ["./init.sh"]
#TODO Arguments passed via 'docker run' will be bitcoind arguments
#Argument 'btcnet'; default is "" (mainnet).
#To run node in testnet or regtest mode, use 'docker run btcnode $btcnet'
CMD [""]
