# btc-dns-box docker image

FROM ubuntu:latest

ENV startscript=start-dns.sh

# Install requirements
RUN apt-get update \
 && apt-get install --yes dnsutils bind9 bind9utils rsyslog tcpdump

RUN mkdir /var/log/named \
&& chown -R bind:root /var/log/named \
&& chmod -R 775 /var/log/named

# Set up BIND9
ENV binddir=./bind
COPY $binddir/named.conf /etc/bind/named.conf
COPY $binddir/zones/seeder.btc.zone /etc/bind/zones/seeder.btc.zone
RUN mkdir /root/mnt

WORKDIR /root/
COPY ./$startscript ./
RUN chmod a+x ./$startscript

EXPOSE 53/udp 53/tcp

ENTRYPOINT ./$startscript
