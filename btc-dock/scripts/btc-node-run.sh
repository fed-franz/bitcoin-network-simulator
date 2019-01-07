#!/bin/bash

source ~/.bash_aliases
start_btc
# \
# && ./btc-node-run.sh $btcdir $datadir $btcnet

while :
do
  # Sleep rand time (0-60 sec)
  randwait=$((RANDOM%300))
  echo "LOOP: sleeping $randwait ..."
	sleep $((60 + $randwait))

  probability=$((RANDOM%100))
  echo "PROBABILITY=$probability"
  if (( $probability <= 50 )); then
    bitcoin-cli getblockchaininfo &> /dev/null
    if [ $? -ne 0 ]; then
      echo "Starting Bitcoin client..."
      start_btc
    else
      echo "Stopping Bitcoin client..."
      stop_btc
    fi
  fi

done
