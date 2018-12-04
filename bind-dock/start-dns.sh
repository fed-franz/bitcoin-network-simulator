#!/bin/sh
# Clear the DNS nameserver imported at runtime by docker
echo "nameserver 127.0.0.1" > /etc/resolv.conf

# Aliases
echo "alias dnslog='tcpdump -i eth0 -vvv -s 0 -l -n port 53 &'" >> ~/.bashrc

# Copy files from mounted directory to bind directory
yes | cp -rf /root/mnt/* /etc/bind/

# Starts log service and BIND9 with log enables
service rsyslog start
/etc/init.d/bind9 start
rndc querylog
chmod -R 0755 /etc/bind/zones/

# Keeps the container running
tail -f /dev/null
