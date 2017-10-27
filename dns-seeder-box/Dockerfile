# btc-dns-box docker image

# Debian
FROM ubuntu:latest

# add bitcoind from the official PPA
RUN apt-get update \
 && apt-get install --yes bind9 bind9utils rsyslog tcpdump

RUN mkdir /var/log/named \
&& chown -R bind:root /var/log/named \
&& chmod -R 775 /var/log/named
# Create command 'dnsdebug'
RUN echo "alias dnsdebug='tcpdump  -vvv -s 0 -l port 53'" >> ~/.bashrc

# Set up BIND9
COPY ./named.conf /etc/bind/named.conf
#COPY ./named.conf.options /etc/bind/named.conf.options
COPY ./seeder.btc.zone /etc/bind/zones/seeder.btc.zone

WORKDIR /root/

EXPOSE 53/udp 53/tcp

ENTRYPOINT service rsyslog start \
	&& /etc/init.d/bind9 start \
  && rndc querylog \
  && /bin/bash
