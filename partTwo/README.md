# aws-educate-test-2

## Part 2

- For information on connecting to an educate account and rolling out infrastucture with Terraform, see the README file in [aws-educate-test](https://github.com/michaelkemp/aws-educate-test)
- Infrastructure in this part does not collide with part 1. They can run together or separately.

## Simple Routing in AWS

- 3 Subnets - 172.31.101.0/24, 172.31.102.0/24, 172.31.103.0/24
- 3 EC2 Instances - 2 Clients in the 101 and 102 subnets, and a Router in the 103 Subnet
- Security Groups such that the 101 and 102 client can only talk to the router
- The router is a t2.small ranter than a t2.micro in order for it to have 3 network interface cards.

## Setup Scripts [user_data]

- Turn on IP Forwarding on the router
```
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
```

- Add routes to the route tables in the clients
```
sudo route add -net 172.31.10x.0 netmask 255.255.255.0 gw 172.31.y.z
```

## Note
- Source/Destination Checks must be turned off for the router and the added network cards for traffic to flow
```
source_dest_check = false
```
