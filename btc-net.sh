#!/bin/bash

### UTILS ###
function check_exit () {
    # "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "ERROR: $1 failed ($status)" >&2
        exit $status
    fi
}


### ENVIRONMENT ###
NUM_NODES=10
NUM_MINERS=1

BASE_NAME="btc"

DNS_DOCK="fedfranz/btcnet-dns"
DNS_NAME=$BASE_NAME"dns"
DNS_IP="10.1.1.2"

BTC_NET=""
LOCALNET=$BASE_NAME"net"

# NODE_DOCK="fedfranz/bitcoinlocal:0.12.0-testnet"
NODE_NAME=$BASE_NAME"node"
NODE_DOCK="fedfranz/btcnet-node"
MINER_DOCK="fedfranz/bitcoinlocal:0.12.0-testnet-miner"
RUN_OPTIONS=""

#RUNTIME COMMANDS OPTIONS
NODE=""

### FUNCTIONS ###
function stop () {
    running_nodes=$(docker ps | grep $BASE_NAME | awk '{print $1}')
    if [ ! -z "$running_nodes" ]; then
      docker stop $running_nodes
    fi
}

function reset () {
  stop
  all_nodes=$(docker ps -a | grep $BASE_NAME | awk '{print $1}')
  if [ ! -z "$all_nodes" ]; then
    docker rm $all_nodes
  fi
}

function getpeers () {
  if [ -z "$1" ]; then
    : #TODO for each node
  else
    nodenum=$1
    docker exec -it btcnode$nodenum /bin/bash -ic "getpeersaddr"
  fi
}

#ARGS
### ARGUMENTS PARSING ###
#TODO: dns IP, subnets
for i in "$@"
do
case $i in
  -n=*|--num-nodes=*)
    NUM_NODES="${i#*=}"
    NODE="${i#*=}" #Used for runtime commands
    shift
  ;;
  -m=*|--num-miners=*)
    NUM_MINERS="${i#*=}"
    shift
  ;;
  -dns=*|--dns_image=*)
    DNS_DOCK="${i#*=}"
    shift
  ;;
  -btc=*|--btc_image=*)
    NODE_DOCK="${i#*=}"
    shift
  ;;
  -net=*|--btc_network=*)
    BTC_NET="${i#*=}"
    shift
  ;;
  -o=*)
    RUN_OPTIONS+=" $i" #TODO Currently unused
    shift
  ;;

  *) # Execute commands
    cmd=$i
    shift
    $cmd $@
    exit 0
  ;;
esac
done

### BEGINNING OF PROGRAM ###
echo "Starting $NUM_NODES nodes and $NUM_MINERS miners"


#Create btcnet - maybe multiple ones
if docker network list | grep -q $LOCALNET
then
  echo "$LOCALNET already exists; skipping..."
else
  #TODO Create multiple networks
  #TODO Take nun of subnets as a parameter
  echo "Creating $LOCALNET network"
  docker network create --internal --subnet 10.1.0.0/16 $LOCALNET
  check_exit "docker network create"
fi


#Update docker images
#TODO Take list of images as a parameter - or just use one image with different tags (take tags list)
# docker pull $NODE_DOCK
# docker pull $MINER_DOCK
# docker pull $DNS_DOCK


#Start DNS
#TODO automatically add first N nodes to the config file, after starting the containers (alternatively, just add the first 10 IPs to the zone file)
#TODO Add zone file on the fly and mount it to overwrite default zone file
if docker ps | grep -q $DNS_NAME
then
  echo "DNS seeder container already exists; skipping..."
else
  echo "Starting Bitcoin DNS seeder"
  runcmd="docker run -d --network=$LOCALNET --ip=$DNS_IP --name=$DNS_NAME $DNS_DOCK"
  echo $runcmd
  $runcmd
  check_exit "docker run $DNS_DOCK"
fi

#TODO Start fixed nodes with specific IPs (those returned by the DNS?)
#Start nodes
for i in $(seq 1 $NUM_NODES)
do
    echo "Starting Bitcoin node container"
    runcmd="docker run -d --network=$LOCALNET --dns=$DNS_IP --name=$NODE_NAME$i $NODE_DOCK $BTC_NET"
    echo $runcmd
    $runcmd
    check_exit "docker run $NODE_DOCK"
done

#TODO Start N vulnerable nodes

#Start miners
for i in $(seq 1 $NUM_MINERS)
do
    echo "Starting Bitcoin miner container"
    docker run -d --network $LOCALNET --dns=$DNS_IP $MINER_DOCK
    check_exit "docker run $MINER_DOCK"
done

#TODO loop nodes on/off
# ./btc-net-nodes.sh $NODE_NAME &
