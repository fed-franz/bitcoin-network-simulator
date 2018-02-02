#!/bin/bash

# BASIC ALGORITHM
# Infinite loop
  # Sleep rand time (0-60 sec)
  # Check balance
  # If balance > 0
    # Send coins with rand % of probability
    # If so
      # Select rand amount  (1-balance satoshis)
      # Select rand dest BTC address from pool  - Nodes share a common pool (access via DNS)
      # Send transaction

#TODO (inside loop?)
#Add receiving addr to pool:
#btc-cli getaccountaddress "" #Current receiving address
#example address mzHGGPUBSQeNdPhaKMrN6EyCaWCDTve5C2

# Infinite loop
while true; do
  # Sleep rand time (0-60 sec)
  sleep $((RANDOM%60))
  # Check balance
  # balance=$(btc-cli getbalance | bc -l)
  balance=$( printf "%.0f\n" $(echo "$(btc-cli getbalance | bc -l) * 100000000" | bc -l) | bc )
  # If balance > 0
  if (( $balance > 0 ))
  then
    # Send coins with rand 10% of probability
    if (( RANDOM%100  >= 90 ))
    then
      # Select rand amount  (1-balance) #TODO: Select dust amount as minimum
      amount=$( printf "%.8f\n" $(echo "$((RANDOM%$balance)) / 100000000" | bc -l) )
      # Select rand dest BTC address from pool  - Nodes share a common pool (access via DNS)

      destaddr="mzHGGPUBSQeNdPhaKMrN6EyCaWCDTve5C2" #TODO pool
      #host -t txt  btc.seeder.btc
      
      # Send transaction
      # btc-cli sendtoaddress $destaddr $amount
      output=$( { btc-cli sendtoaddress $destaddr $amount ; } 2>&1)
      if (( $? > 0 )); then echo $output; fi
    fi
  fi
done
