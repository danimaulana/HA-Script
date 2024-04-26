#!/bin/bash

# Backup the original network configuration file
sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml

# Create a new network configuration file with the desired IP address
cat << EOF | sudo tee /etc/netplan/00-installer-config.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses: [192.168.122.0/24] # 192.168.122.61-65
      gateway4: 192.168.122.1
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8] # DNS servers
EOF

# Apply the new network configuration
sudo netplan apply
