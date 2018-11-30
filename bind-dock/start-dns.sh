#!/bin/sh
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "alias dnslog='tcpdump -i eth0 -vvv -s 0 -l -n port 53 &'" >> ~/.bashrc

service rsyslog start
/etc/init.d/bind9 start
rndc querylog
chmod -R 0777 /etc/bind/zones/
tail -f /dev/null
