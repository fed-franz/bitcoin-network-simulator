#!/bin/bash
#TODO Use argument parser

# Clear the DNS nameserver imported at runtime by docker
if [ -z "$2" ]; then
  dnsip="10.1.1.2"
else
  dnsip="$2"
fi
echo "nameserver $dnsip" > /etc/resolv.conf

# Get Arguments
btcdir="./btc"
btcnet=$1
#TODO Get bitcoind arguments

# Copy files from mounted directory to bind directory (if any)
yes | cp -rf /root/mnt/* /btc/ 2>/dev/null

# Aliases
# datadir=$btcdir/data
datadir=$HOME/.bitcoin
logdir=
obtcnet=""
case "$btcnet" in
 "testnet")
    obtcnet="-testnet"
    logdir=$datadir/testnet3
    ;;
 "regtest")
    obtcnet="-regtest"
    logdir=$datadir/regtest
    ;;
  *)
    btccli="bitcoin-cli"
    logdir=$datadir

esac

btcd="bitcoind $obtcnet -onlynet=ipv4 -logips"
btccli="bitcoin-cli $obtcnet"

echo \
"alias bitcoind='btcd'
alias bitcoin-cli='$btccli'
alias getblockcount='$btccli getblockcount'
alias getpeers='$btccli getpeerinfo'
alias getpeersaddr=\"getpeers | grep -E '\\\"addr\\\": \\\"|inbound'\"
alias btcstart='$btcd'
alias btcstop='$btccli stop'
alias getlog='cat $logdir/debug.log'"\
 >> ~/.bashrc

echo \
"
function start_btc () {
 $btcd -daemon
}

function stop_btc () {
 $btccli stop
}
"\
>> ~/.bash_aliases

# source ~/.bashrc
./btc-node-run.sh
