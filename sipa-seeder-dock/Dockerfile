# btc-seeder docker image

# Debian
FROM ubuntu:latest

#ENV var=val

RUN apt-get update && apt-get --yes upgrade
# Install sipa seeder requirements
# RUN apt-get install --yes build-essential libboost-all-dev libssl-dev
RUN apt-get install --yes libssl-dev
# Install DNS utils
# RUN apt-get install --yes net-tools dnsutils tcpdump
# dnsutils -> nslookup
# netcat   -> nc

# Copy bin and script files
# COPY ./bitcoin-seeder /root/bitcoin-seeder
# WORKDIR /root/bitcoin-seeder
# RUN make
# WORKDIR /root/
COPY ./bitcoin-seeder/dnsseed /usr/local/bin/dnsseed
COPY ./sipa-start.sh /root/start.sh

# RUN ln -s /root/bitcoin-seeder/dnsseed /usr/local/bin/dnsseed
#RUN ln -s /root/start.sh /usr/local/bin/start-dnsseed

# Expose Bitcoin ports
EXPOSE 53/udp 53/tcp 8333 18333

ENTRYPOINT ["/bin/bash"]
#dnsseed --testnet -t 10 -h sipa.seeder.com -n vps.seeder.com -m admin@seeder.com

# dnsseed --testnet -t 50 -h seed.seeder.btc -n vps.seeder.btc -m admin.seeder.btc
