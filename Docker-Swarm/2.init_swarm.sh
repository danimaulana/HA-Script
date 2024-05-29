#!/bin/bash

# Daftar alamat IP untuk node master dan worker
MASTER_IPS=("192.168.122.61" "192.168.122.62" "192.168.122.63")
WORKER_IPS=("192.168.122.64" "192.168.122.65")

# Kata sandi untuk autentikasi SSH dan sudo
SSH_PASSWORD="ubuntu"
SUDO_PASSWORD="ubuntu"

# Periksa dan instal sshpass jika belum ada
if ! command -v sshpass &> /dev/null; then
    echo "sshpass not found, installing..."
    sudo apt-get update
    sudo apt-get install -y sshpass
fi

# Fungsi untuk memeriksa apakah node sudah menjadi bagian dari Swarm
check_swarm_status() {
    if sudo docker info | grep -q "Swarm: active"; then
        echo "Node is already part of a swarm."
        return 1
    else
        return 0
    fi
}

# Inisialisasi Swarm pada node master pertama jika belum menjadi bagian dari Swarm
if check_swarm_status; then
    echo $SUDO_PASSWORD | sudo -S docker swarm init --advertise-addr ${MASTER_IPS[0]}
else
    echo "Node ${MASTER_IPS[0]} is already part of a swarm. Skipping initialization."
fi

# Mendapatkan token untuk bergabung dengan Swarm sebagai manager dan worker
MANAGER_JOIN_TOKEN=$(echo $SUDO_PASSWORD | sudo -S docker swarm join-token -q manager)
WORKER_JOIN_TOKEN=$(echo $SUDO_PASSWORD | sudo -S docker swarm join-token -q worker)

# Tampilkan token untuk bergabung dengan Swarm
echo "Manager join token: $MANAGER_JOIN_TOKEN"
echo "Worker join token: $WORKER_JOIN_TOKEN"

# Fungsi untuk bergabungkan node ke Swarm
join_swarm() {
    local node_ip=$1
    local token=$2
    sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no ubuntu@$node_ip "echo $SUDO_PASSWORD | sudo -S docker swarm join --token $token ${MASTER_IPS[0]}:2377"
}

# Bergabungkan node master tambahan ke Swarm
for ((i=1; i<${#MASTER_IPS[@]}; i++))
do
  join_swarm "${MASTER_IPS[$i]}" "$MANAGER_JOIN_TOKEN"
done

# Bergabungkan node worker ke Swarm
for ((i=0; i<${#WORKER_IPS[@]}; i++))
do
  join_swarm "${WORKER_IPS[$i]}" "$WORKER_JOIN_TOKEN"
done

echo "Swarm initialization and node join process completed."
