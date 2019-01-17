#!/bin/bash

### ENVIRONMENT ###
BTC_NET="testnet"

NUM_NODES=10
NUM_MINERS=1

BASE_NAME="btc"
LOCALNET=$BASE_NAME"net"

DNS_NAME=$BASE_NAME"dns"
DNS_DOCK="fedfranz/btcnet-dns"
DNS_IP="10.1.1.2"


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
function get_next_ips () {
  #TODO Check mandatory argument
  n=$1

  # Get highest IP
  zonefile="/etc/bind/zones/seeder.btc.zone"
  #NOTE This assumes addresses are in ascending order (last ip is the highest)
  lastip=$(docker exec -it $DNS_NAME /bin/bash -ic "tail -n 1 $zonefile" | awk 'END {print $NF}' | tr -d '\015')
  lastoctet=${lastip##*.}

  # Write new addresses
  first=$(expr $lastoctet + 1)
  last=$(expr $first + $n - 1)
  iplist=""
  #TODO if $i=254 -> i=1 j=1 (10.1.$j.$i)
  for i in $(seq $first $last)
  do
    iplist+="10.1.0.$i "
  done

  echo $iplist
}

# Add new addresses to the DNS
function update_dns () {
  # Parse arguments
  for i in "$@" ; do
    case $i in
      -n=*) #Add the next $n addresses (in increasing order)
        n="${i#*=}"
        iplist=($(get_next_ips $n))
        shift
      ;;
      *) # Take list of addresses as arguments
        iplist=("$@")
    esac
  done

  # Add each address to the zone file
  for i in "${iplist[@]}"
  do
    echo Adding: $i
    docker exec -it $DNS_NAME /bin/bash -ic "echo \"seed IN A $i\" >> /etc/bind/zones/seeder.btc.zone"
  done

  # Restart BIND
  docker exec -it $DNS_NAME /bin/bash -ic "/etc/init.d/bind9 restart"
}

# Update DNS zone file
function update_zonefile () {
  zonefile="./bind-dock/mnt/zones/seeder.btc.zone"
  n=$1
  overwrite=$2

  # Are we overwriting the file or adding new addresses ?
  if [ "$overwrite" = true ] ; then
    # Delete current seed addresses
    sed -i '/seed\sIN\sA/d' $zonefile
    first=1
  else
    # Get the last ip's last octet
    #NOTE This assumes addresses are in ascending order (last ip is the highest)
    #TODO Take other octets into account
    lastip=$(awk 'END {print $NF}' $zonefile)
    lastoctet=${lastip##*.}
    first=$(expr $lastoctet + 1)
  fi

  # Write new addresses
  last=$(expr $first + $n - 1)
  for i in $(seq $first $last)
  do
    #TODO if $i=254 -> i=1 j=1 (10.1.$j.$i)
    echo "seed	IN	A	10.1.0.$i" >> $zonefile
  done
}

# Run DNS container
function run_dns () {
  update=false
  overwrite=false
  numnodes=$NUM_NODES
  mount=""

  for i in "$@"
  do
  case $i in
    -i=*|--image=*)
      DNS_DOCK="${i#*=}"
      shift
    ;;
    -ip=*)
      DNS_IP="${i#*=}"
      shift
    ;;
    -u|--update)
      update=true
      shift
    ;;
    -o|--overwrite) #NOTE Valid when updating
      overwrite=true
      shift
    ;;
    -n=*|--numnodes=*) #NOTE Valid when updating
      numnodes="${i#*=}"
      shift
    ;;
    *) # Ignore
      shift
    ;;
  esac
  done

  if [ $update = true ] ; then
    update_zonefile $numnodes $overwrite
    mount="  -v $(pwd)/bind-dock/mnt:/root/mnt"

    #Restart DNS container
    if docker ps | grep -q $DNS_NAME ; then
      echo "Stopping DNS container"
      docker stop $DNS_NAME
      sleep 3
    fi
  fi

  # Run DNS container
  echo "Starting DNS container"
  cmd="docker run -d --rm --network=$LOCALNET --ip=$DNS_IP --name=$DNS_NAME $mount $DNS_DOCK"
  echo $cmd
  $cmd
}

# Run nodes
function run_nodes () {
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
    echo "Starting $ctype containers ($n)"
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
  ctype=$1
  n=$2
  run_nodes $ctype $n $LOCALNET

  update_dns -n=$n
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

  #TODO Update docker images ? - Take as option
  #TODO Take list of images as a parameter - or just use one image with different tags (take tags list)
  # docker pull $NODE_DOCK
  # docker pull $MINER_DOCK
  # docker pull $DNS_DOCK

  #TODO Start fixed nodes with specific IPs (those returned by the DNS?)
  if docker ps | grep -q $DNS_NAME
  then
    echo "DNS seeder container already exists; skipping..."
  else
    #TODO Get options to choose if to run DNS dynamic (-u -o) or not OR get number of addresses to add to DNS (-n=N)
    tot_nodes=$(($NUM_NODES + $NUM_MINERS))
    run_dns -u -o -n=$tot_nodes
  fi

  run_nodes "node" $NUM_NODES $LOCALNET
  run_nodes "miner" $NUM_MINERS $LOCALNET
}

# Stop simulation (stop all containers)
function stop () {
    running_nodes=$(docker ps | grep $BASE_NAME | awk '{print $1}')
    if [ ! -z "$running_nodes" ]; then
      docker stop $running_nodes
    fi
}

# Reset simulation (stop and remove all containers)
function reset () {
  stop
  all_nodes=$(docker ps -a | grep $BASE_NAME | awk '{print $1}')
  if [ ! -z "$all_nodes" ]; then
    docker rm $all_nodes
  fi
}

# Prints node's IP address
function getnodeaddr () {
  nodenum=$1

  nodeaddr=$(docker exec -it $NODE_NAME$nodenum /bin/bash -ic "ifconfig eth0" | grep "inet " | cut -d: -f2 | awk '{print $1}')
  echo $nodeaddr
}

# ParsePeers
function parsepeers () {
  if [ -z "$1" ]; then
    echo "ERR: nodename expected"; exit 1
  fi
  nodename=$1 #NODE_NAME

  getpeers=$(docker exec -it $nodename /bin/bash -ic "getpeersaddr")

  # Check for errors (error output means node's offline)
  err=$(echo "$getpeers" | grep error | wc -l)
  if (( $err > 0 )); then
    echo "Node offline"
  else
    peers=$(echo "$getpeers" | sed 's/^ *//' | cut -d' ' -f2 | sed -e 's/,//' -e 's/^"//' -e 's/"//' | tr -d '\015')
    IFS=$'\n' array=($peers)

    index=0
    declare -A LIST
    for (( i = 0; i < ${#array[@]}; i=i+2 )); do
      LIST[$index,0]=${array[$i]}
      LIST[$index,1]=${array[$((i+1))]}
      index=$((index+1))
    done
    index=$((index-1))

    for i in $(seq 0 $(($index-1))); do
      echo "${LIST[$i,0]} ($([[ ${LIST[$i,1]} = true ]] && echo "inbound" || echo "outbound"))"
    done
  fi
}

# Prints current peers connections
function getpeers () {
  if [ ! -z "$1" ]; then
    parsepeers $NODE_NAME$1
  else
    numnodes=$(docker ps -a | grep $NODE_NAME | wc -l)
    for i in $(seq 1 $numnodes)
    do
      echo "$NODE_NAME$i ($(getnodeaddr $i))"
      parsepeers $NODE_NAME$i
    done
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
