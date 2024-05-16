#!/bin/bash

# Update the package list
apt update

# Install some prerequisite packages
apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the Docker repository to Apt sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package list again
apt-get update

# Install Docker packages
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add the current user to the docker group
usermod -aG docker ${USER}

# Verify Docker installation
docker run hello-world

# Install docker-compose
sudo apt install -y docker-compose

# Add the current user to the docker group (again for docker-compose)
usermod -aG docker ${USER}

# Switch to the current user to apply group changes
su - ${USER}

# Check Docker status
systemctl status docker
