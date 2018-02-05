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

#TODO (inside loop?) - After every transaction ?
#Add receiving addr to pool:
(echo "update add btc.seeder.btc 86400 txt $(btc-cli getaccountaddress "")" ; echo send) | nsupdate


# Infinite loop
while true; do
  #TODO Go offline with X probability (stop container)

  # Sleep rand time (0-60 sec)
  sleep $((RANDOM%60))
  # Check balance
  # balance=$(btc-cli getbalance | bc -l)
  balance=$( printf "%.0f\n" $(echo "$(btc-cli getbalance | bc -l) * 100000000" | bc -l) | bc )
  # If balance > 0
  if (( $balance > 0 ))
  then
    # Send coins with rand 10% of probability
    #TODO Tune probability
    if (( RANDOM%100  >= 90 ))
    then
      # Select rand amount  (1-balance)
      #TODO Select dust amount as minimum
      #TODO Tune probability
      amount=$( printf "%.8f\n" $(echo "$((RANDOM%$balance)) / 100000000" | bc -l) )

      # Select rand dest BTC address from pool  - Nodes share a common pool (access via DNS)
      destaddr=$(host -t txt  btc.seeder.btc | head -n 1 | awk 'END {print $NF}')

      # Send transaction
      output=$( { btc-cli sendtoaddress $destaddr $amount ; } 2>&1)
      if (( $? > 0 )); then echo $output; fi
    fi
  fi
done
