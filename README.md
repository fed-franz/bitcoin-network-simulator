# Local Bitcoin Network
It allows to locally simulate a Bitcoin network with Docker.
Currently working with Testnet only.

Use 'btc-net-start.sh' to:
1. Create an isolated /16 IP4 network (btcnet)
2. Run the BIND DNS server at IP 10.1.1.2
3. Run nodes and miners

### Usage
'./btc-net-start.sh <number-of-nodes> <number-of-miners>'

Default parameters are:  
- number-of-nodes = 100  
- number-of-miners = 10  

### DNS
Build:
`docker build -t btcnet-dns .`  
Run:
`docker run -d --rm --network btcnet --ip 10.1.1.2 --name=btcdns btcnet-dns`  
Check if the DNS is working:
`nslookup seed.seeder.btc 10.1.1.2`  
Stop:
`docker stop btcdns`  

To overwrite BIND files without rebuilding the container you can mount a folder at `/root/mnt`.
Files in this folder will be copied recursively into `/etc/bind` and overwrite default files.  
In order to work properly, the mounted folder must have the same structure as `/etc/bind`. See `bind` folder in this repo as a reference.  
You can use docker's `-v` option to mount the folder at runtime.  
For instance:  
`docker run -d --rm --network btcnet --ip 10.1.1.2 --name=btcdns -v $(pwd)/bind:/root/mnt fedfranz/btcnet-dns`  

To check the log, you can execute the following command:  
`docker exec -it btcdns tcpdump -i eth0 -vvv -s 0 -l -n port 53`  
or run a bash terminal and then execute the command `dnslog`:  
```
$ docker exec -it btcdns /bin/bash
# dnslog
```
