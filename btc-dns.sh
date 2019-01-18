#!/bin/bash

### ENVIRONMENT ###
#NOTE This variables should be set by the btc-net script:
# BASE_NAME LOCALNET BTC_NET_SUBNET
#TODO Check if these variables are set

DNS_NAME=$BASE_NAME"dns"
DNS_DOCK="fedfranz/btcnet-dns"
DNS_IP="10.1.1.2"

ZONEFILE="seeder.btc.zone"
ZONEPATHNAME="/etc/bind/zones/$ZONEFILE"

SUBNET=$BTC_NET_SUBNET

### FUNCTIONS ###
function get_next_ips () {
  #TODO Check mandatory argument
  n=$1

  # Get highest IP
  #NOTE This assumes addresses are in ascending order (last ip is the highest)
  lastip=$(docker exec -it $DNS_NAME /bin/bash -ic "tail -n 1 $ZONEPATHNAME" | awk 'END {print $NF}' | tr -d '\015')
  lastoctet=${lastip##*.}

  # Write new addresses
  first=$(expr $lastoctet + 1)
  last=$(expr $first + $n - 1)
  iplist=""
  #TODO if $i=254 -> i=1 j=1 (10.1.$j.$i)
  for i in $(seq $first $last)
  do
    iplist+="$SUBNET.$i "
  done

  echo $iplist
}

# Add new addresses to the running DNS
# Takes a list of addresses or -n=N number of new addresses to be automatically created
function update_dns () {
  #TODO Check if DNS is active

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
  echo "Updating DNS ($ZONEFILE)"
  for i in "${iplist[@]}"
  do
    docker exec -it $DNS_NAME /bin/bash -ic "echo \"seed IN A $i\" >> $ZONEPATHNAME"
  done
  echo "Added addresses to DNS:"
  echo "${iplist[@]}"

  # Restart BIND
  docker exec -it $DNS_NAME /bin/bash -ic "/etc/init.d/bind9 restart"
}

# Update DNS zone file (for dynamic container)
ZONEPATHNAME_MNT="./bind-dock/mnt/zones/$ZONEFILE"
function update_zonefile () {
  n=$1
  overwrite=$2

  # Are we overwriting the file or adding new addresses ?
  if [ "$overwrite" = true ] ; then
    # Delete current seed addresses
    sed -i '/seed\sIN\sA/d' $ZONEPATHNAME_MNT
    first=1
  else
    # Get the last ip's last octet
    #NOTE This assumes addresses are in ascending order (last ip is the highest)
    #TODO Take other octets into account
    lastip=$(awk 'END {print $NF}' $ZONEPATHNAME_MNT)
    lastoctet=${lastip##*.}
    first=$(expr $lastoctet + 1)
  fi

  # Write new addresses
  last=$(expr $first + $n - 1)
  for i in $(seq $first $last)
  do
    #TODO if $i=254 -> i=1 j=1 (10.1.$j.$i)
    echo "seed	IN	A	$SUBNET.$i" >> $ZONEPATHNAME_MNT
  done
}

# Run DNS container
function run_dns () {
  #Stop DNS container if running
  if docker ps | grep -q $DNS_NAME ; then
    echo "Stopping DNS container"
    docker stop $DNS_NAME
    sleep 3 #Wait for the container to stop before starting it again
  fi

  #Set up environment
  dynamic=false
  numnodes=0
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

    -d|--dynamic)
      dynamic=true
      shift
    ;;
    -n=*|--numnodes=*) #NOTE Valid with dynamic mode
      numnodes="${i#*=}"
      shift
    ;;
    *) # Ignore
      shift
    ;;
  esac
  done

  #If in dyanmic mode, updates the zonefile file and mount it to the container
  if [ $dynamic = true ] ; then
    #TODO Allow getting list of addresses as a parameter
    update_zonefile $numnodes true
    mount=" -v $(pwd)/bind-dock/mnt:/root/mnt"
  fi

  # Run DNS container
  echo "Starting DNS container"
  cmd="docker run -d --rm --network=$LOCALNET --ip=$DNS_IP --name=$DNS_NAME $mount $DNS_DOCK"
  echo $cmd
  $cmd
}
