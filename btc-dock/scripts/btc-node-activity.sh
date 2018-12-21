#!/bin/bash

# BASIC ALGORITHM
# Add receiving addr to pool
# Infinite loop
  # Sleep rand time (0-60 sec)
  # Check balance
  # If balance > 0
    # Send coins with rand % of probability
    # If so
      # Select rand amount  (1-balance satoshis)
      # Select rand dest BTC address from pool  - Nodes share a common pool (access via DNS)
      # Send transaction

#Wait for bitcoind to be fully loaded
echo -n "Loading"
btc-cli getblockchaininfo > /dev/null 2>&1
while [ $? = 28 ]; do
  echo -n "."
  sleep 1
  btc-cli getblockchaininfo > /dev/null 2>&1
done
echo " Done"

#Add receiving addr to pool:
#TODO (put it inside loop?) - After every transaction ?
echo "Sending BTC address to pool"
(echo "update add btc.seeder.btc 86400 txt $(btc-cli getaccountaddress "")" ; echo send) | nsupdate

# Infinite loop
while true; do
  echo "Loop round"
  #TODO Go offline with X probability (stop container)

  # Sleep rand time (0-60 sec)
  sleep $((RANDOM%300))
  # Check balance
  balance=$( printf "%.0f\n" $(echo "$(btc-cli getbalance | bc -l) * 100000000" | bc -l) | bc )
  echo "balance=$balance"
  if (( $balance > 0 ))
  then
    # Send coins with rand 10% of probability
    #TODO Tune probability - according to per-node tx rate (~ 1/sec total in network)
    if (( RANDOM%100  >= 50 ))
    then
      echo "Preparing new transaction"
      # Select rand amount  (1-balance)
      #TODO Select dust amount as minimum - the default dust limit in 0.14.0+ is 546 satoshis
      ## Maybe we can just ignore it.
      #TODO Tune probability ? According to what?
      amount=$( printf "%.8f\n" $(echo "$((RANDOM%$balance)) / 100000000" | bc -l) )

      # Select rand dest BTC address from pool  - Nodes share a common pool (access via DNS)
      destaddr=$(host -t txt  btc.seeder.btc | head -n 1 | grep -oP '"\K[^"]+')

      echo "Sending $amount satoshis to $destaddr"

      # Send transaction
      output=$( { btc-cli sendtoaddress $destaddr $amount ; } 2>&1)
      if (( $? > 0 )); then echo $output; fi

      echo $output

    fi
  fi
done
