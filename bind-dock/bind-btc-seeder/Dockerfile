# btc-dns-box docker image

FROM ubuntu:latest

# add bitcoind from the official PPA
RUN apt-get update \
 && apt-get install --yes bind9 bind9utils rsyslog tcpdump

RUN mkdir /var/log/named \
&& chown -R bind:root /var/log/named \
&& chmod -R 775 /var/log/named

# Set up BIND9
COPY ./named.conf /etc/bind/named.conf
COPY ./seeder.btc.zone /etc/bind/zones/seeder.btc.zone
COPY ./btc.seeder.btc.zone /etc/bind/zones/btc.seeder.btc.zone
RUN echo "alias dnslog='tcpdump -i eth0 -vvv -s 0 -l -n port 53 &'" >> ~/.bashrc

WORKDIR /root/

EXPOSE 53/udp 53/tcp

ENTRYPOINT service rsyslog start \
	&& echo "nameserver 127.0.0.1" > /etc/resolv.conf \
	&& /etc/init.d/bind9 start \
	&& rndc querylog \
  && chmod -R 0777 /etc/bind/zones/ \
	&& tail -f /dev/null
