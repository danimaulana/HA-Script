#!/bin/bash

# Update the package list
sudo apt update

# Install some prerequisite packages
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add the Docker repository to Apt sources
sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the package list again
sudo apt update

# Install Docker packages
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Verify Docker installation
sudo docker run hello-world

# Remove hello-world image
sudo docker rmi hello-world

# Install docker-compose
sudo apt install -y docker-compose

# Add the current user to the docker group
sudo usermod -aG docker $USER

# Check Docker status
sudo systemctl status docker
