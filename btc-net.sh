#!/bin/bash

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


### UTILS ###
function check_exit () {
    # "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "ERROR: $1 failed ($status)" >&2
        exit $status
    fi
}


### FUNCTIONS ###

# Run nodes
function runcontainers () {
  ctype=$1
  n=$2
  net=$3
  options=$4
  basename=""
  imagename=""

  case $ctype in
    "node")
      basename="btcnode"
      imagename=$NODE_DOCK
    ;;
    "miner")
      basename="btcminer"
      imagename=$MINER_DOCK
    ;;
    "dns")
      basename="btcdns"
      imagename=$DNS_DOCK
    ;;
    *)
      echo "$ctype is not a valid container type. Aborting..."
      exit 1
  esac

  if (( $n > 0 )); then
    #Check if other nodes of the same type are running
    running=$(docker ps | grep $basename)
    if [ -z "$running" ]; then
      first=1
      last=$n
    else
      #Get highest container ID number
      lastrunning=$(docker ps | grep $basename | sed -e 's/.*[^0-9]\([0-9]\+\)[^0-9]*$/\1/' | sort -n | tail -1)
      first=$(expr 1 + $lastrunning)
      last=$(expr $first + $n - 1)
    fi

    #Run containers
    echo "Starting $ctype containers"
    for i in $(seq $first $last)
    do
        runcmd="docker run -d --network=$net --dns=$DNS_IP $options --name=$basename$i $imagename $BTC_NET"
        echo $runcmd && $runcmd
        check_exit "docker run $imagename"
    done
  fi
}

# Run new nodes
# Args:
#   $1 : container type (node|miner|dns)
#   $2 : number of containers to start
function run () {
  #TODO get network as parameter - check if no $3, set net=$LOCALNET

  runcontainers $1 $2 $LOCALNET
}

# Start simulation
function start () {
  #Create network
  if docker network list | grep -q $LOCALNET
  then
    echo "$LOCALNET already exists; skipping..."
  else
    #TODO Create multiple networks
    #TODO Take num of subnets as a parameter
    echo "Creating $LOCALNET network"
    docker network create --internal --subnet 10.1.0.0/16 $LOCALNET
    check_exit "docker network create"
  fi

  #TODO Update docker images ?
  #TODO Take list of images as a parameter - or just use one image with different tags (take tags list)
  # docker pull $NODE_DOCK
  # docker pull $MINER_DOCK
  # docker pull $DNS_DOCK

  #TODO Start fixed nodes with specific IPs (those returned by the DNS?)
  echo "Starting $NUM_NODES nodes and $NUM_MINERS miners"
  if docker ps | grep -q $DNS_NAME
  then
    echo "DNS seeder container already exists; skipping..."
  else
    #TODO ? automatically add first N nodes to the config file, after starting the containers (alternatively, just add the first 10 IPs to the zone file)
    #TODO ? Add zone file on the fly and mount it to overwrite default zone file
    runcontainers "dns" 1 $LOCALNET "--ip=$DNS_IP"
  fi
  runcontainers "node" $NUM_NODES $LOCALNET
  runcontainers "miner" $NUM_MINERS $LOCALNET
}

# Stop simultion
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

### BEGINNING OF PROGRAM ###

#Parse arguments
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

start

#TODO loop nodes on/off
# ./btc-net-nodes.sh $NODE_NAME &
