#!/bin/bash

# Backup the original network configuration file
sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml

# Create a new network configuration file with the desired IP address
cat << EOF | sudo tee /etc/netplan/00-installer-config.yaml
network:
  ethernets:
    enp1s0:
      dhcp4: false 
      addresses: [192.168.122.0/24]  #192.168.122.61-65
      gateway4: 192.168.122.1  # IP
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]  # DNS
  version: 2

EOF

# Apply the new network configuration
sudo netplan apply
