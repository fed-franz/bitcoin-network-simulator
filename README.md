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

To check if the DNS is working, use the following command:
`nslookup seed.seeder.btc SERVER_IP_ADDRESS`
