#!/bin/bash

# Daftar alamat IP node-node yang akan diinstal Docker
NODE_IPS=("192.168.122.61" "192.168.122.62" "192.168.122.63" "192.168.122.64" "192.168.122.65")

# Fungsi untuk menjalankan skrip di node yang ditentukan melalui SSH
run_script_on_node() {
    local node_ip=$1
    local script=$2
    echo "Running script on $node_ip..."
    ssh ubuntu@$node_ip "bash -s" < $script
    echo "Script execution on $node_ip finished."
}

# Skrip instalasi Docker
DOCKER_INSTALL_SCRIPT="#!/bin/bash\n\n
# Update the package list\n
sudo apt update\n\n
# Install some prerequisite packages\n
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common\n\n
# Add Docker's official GPG key\n
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -\n\n
# Add the Docker repository to Apt sources\n
sudo add-apt-repository \"deb [arch=\$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\"\n\n
# Update the package list again\n
sudo apt update\n\n
# Install Docker packages\n
sudo apt install -y docker-ce docker-ce-cli containerd.io\n\n
# Verify Docker installation\n
sudo docker run hello-world\n\n
# Remove hello-world image\n
sudo docker rmi hello-world\n\n
# Install docker-compose\n
sudo apt install -y docker-compose\n\n
# Add the current user to the docker group\n
sudo usermod -aG docker \$USER\n\n
# Check Docker status\n
sudo systemctl status docker\n
# Exit SSH session
exit\n"

# Menjalankan instalasi Docker pada setiap node
for ip in "${NODE_IPS[@]}"; do
    echo "Copying script to $ip..."
    echo -e "$DOCKER_INSTALL_SCRIPT" | ssh ubuntu@$ip "cat > /tmp/install_docker.sh"
    echo "Script copied to $ip."
    echo "Running script on $ip..."
    ssh ubuntu@$ip "bash /tmp/install_docker.sh"
    echo "Script execution on $ip finished."
done

echo "Docker installation completed on all nodes."
