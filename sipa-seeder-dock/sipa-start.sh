#!/bin/bash
SEED=127.0.0.1
HOST=host.seeder.btc
NAMESERVER=seeder.btc
#P2PORT=9377
#MAGIC=FACABADA
SOA=dns.seeder.btc
#TOR=127.0.0.1:9050
CRAWLER_THREADS=10
DNSSERVER_THREADS=10

dnsseed \
-h ${HOST} \
-n ${NAMESERVER} \
--seed ${SEED} \
-t ${CRAWLER_THREADS} -d ${DNSSERVER_THREADS}
-m ${SOA}
#-o ${TOR} \
#--p2port ${P2PORT} \
#--magic ${MAGIC} \
