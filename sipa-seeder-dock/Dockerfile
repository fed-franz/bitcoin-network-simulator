# Bitcoin Seeder SIPA

FROM ubuntu:latest

RUN apt-get update && apt-get --yes upgrade
RUN apt-get install --yes libssl-dev
# Install DNS utils
# RUN apt-get install --yes net-tools dnsutils tcpdump
# dnsutils -> nslookup
# netcat   -> nc

COPY ./bitcoin-seeder/dnsseed /usr/local/bin/dnsseed
COPY ./sipa-start.sh /root/start.sh

# Expose Bitcoin ports
EXPOSE 53/udp 53/tcp 8333 18333

ENTRYPOINT ["/bin/bash"]
#RUN
# docker run -it --rm --network=btcnet --ip=10.1.2.2 --dns=10.1.1.2 --name=btcdns-sipa btcdns:sipa
# dnsseed --testnet -t 10 -h seed.seeder.btc -n vps.seeder.btc -m admin@seeder.btc
