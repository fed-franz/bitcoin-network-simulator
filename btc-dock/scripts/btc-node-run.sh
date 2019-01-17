#!/bin/bash

source ~/.bash_aliases
start_btc
# \
# && ./btc-node-run.sh $btcdir $datadir $btcnet

while :
do
  # Sleep rand time (30-120 sec)
  randwait=$((RANDOM%90 + 30))
  echo "SLEEP $randwait seconds..."
	sleep $(($randwait))

  probability=$((RANDOM%100))
  echo "PROB=$probability (90+ triggers action)"
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
