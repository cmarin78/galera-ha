#!/bin/bash

echo -e "\e[44;1mAuth Maxscale Nodes and Creating PCS Cluster... \e[0m"
sleep 5

pcs cluster auth maxscale01 maxscale02 maxscale03 -u hacluster -p hacluster
pcs cluster setup --name maxscale_cluster maxscale01 maxscale02 maxscale03
pcs cluster enable --all
pcs cluster start --all
pcs property set stonith-enabled=false
pcs property set no-quorum-policy=ignore
pcs resource create maxscale systemd:maxscale op monitor interval=1s
pcs resource clone maxscale
pcs resource create maxscale_ip ocf:heartbeat:IPaddr2 ip=10.10.0.220 cidr_netmask=21 nic=eth0 op monitor interval=20s
pcs resource meta maxscale_ip migration-threshold=1 failure-timeout=60s resource-stickiness=100
pcs resource meta maxscale-clone migration-threshold=1 failure-timeout=60s resource-stickiness=100
pcs constraint colocation add maxscale_ip with maxscale-clone INFINITY

echo -e "\e[44;1mEnding Pacemaker Configuration... \e[0m"
sleep 5
