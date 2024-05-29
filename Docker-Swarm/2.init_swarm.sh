#!/bin/bash

# List of IP addresses for master and worker nodes
MASTER_IPS=("192.168.122.61" "192.168.122.62" "192.168.122.63")
WORKER_IPS=("192.168.122.64" "192.168.122.65")

# SSH password for authentication
SSH_PASSWORD="ubuntu"

# Initialize Swarm on the first master node
docker swarm init --advertise-addr ${MASTER_IPS[0]}

# Get token for joining the Swarm as additional master nodes
JOIN_TOKEN=$(docker swarm join-token -q worker)

# Join additional master nodes to the Swarm
for ((i=1; i<${#MASTER_IPS[@]}; i++))
do
  sshpass -p "$SSH_PASSWORD" ssh ubuntu@${MASTER_IPS[$i]} "docker swarm join --token $JOIN_TOKEN ${MASTER_IPS[0]}:2377"
done

# Join worker nodes to the Swarm
for ((i=0; i<${#WORKER_IPS[@]}; i++))
do
  sshpass -p "$SSH_PASSWORD" ssh ubuntu@${WORKER_IPS[$i]} "docker swarm join --token $JOIN_TOKEN ${MASTER_IPS[0]}:2377"
done
