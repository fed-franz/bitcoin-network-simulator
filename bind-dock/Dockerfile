# btc-dns-box docker image

FROM ubuntu:latest

ENV startscript=start-dns.sh

# Install requirements
RUN apt-get update \
 && apt-get install --yes bind9 bind9utils rsyslog tcpdump

RUN mkdir /var/log/named \
&& chown -R bind:root /var/log/named \
&& chmod -R 775 /var/log/named

# Set up BIND9
COPY ./named.conf /etc/bind/named.conf
COPY ./seeder.btc.zone /etc/bind/zones/seeder.btc.zone
#COPY ./btc.seeder.btc.zone /etc/bind/zones/btc.seeder.btc.zone

WORKDIR /root/
COPY ./$startscript ./
RUN chmod a+x ./$startscript

EXPOSE 53/udp 53/tcp

ENTRYPOINT ./$startscript

#TODO Check if seeder.btc.zone file in "mount" path. At runtime mount folder to overwrite default file
