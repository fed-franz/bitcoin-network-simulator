#!/bin/bash

source ~/.bash_aliases
start_btc
# \
# && ./btc-node-run.sh $btcdir $datadir $btcnet

myip=$(btc-cli getaccountaddress "")
seed	IN	A	10.1.0.1
(echo "update add seed.seeder.btc 86400 A $myip" ; echo send) | nsupdate
# (echo "update add seed.seeder.btc 86400 txt $myip" ; echo send) | nsupdate

echo "server 10.1.1.2.
zone seeder.btc.
update add seed.seeder.btc. 86400 A 10.1.0.2
send" | nsupdate

while :
do
  # Sleep rand time (30-120 sec)
  randwait=$((RANDOM%90 + 30))
  echo "SLEEP $randwait seconds..."
	sleep $(($randwait))

  probability=$((RANDOM%100))
  echo "PROB=$probability (90+ triggers action)"
  #TODO Increase probability if btc is off
  if (( $probability >= 90 )); then
    date +"%Y-%m-%d %H:%M:%S"
    check_btc
    if [ $? -ne 0 ]; then
      echo "start_btc"
      start_btc
    else
      echo "stop_btc"
      stop_btc
    fi
  fi

done
