import docker
import time
import pytz
from datetime import datetime

# Inisialisasi klien Docker
client = docker.from_env()

# Fungsi untuk mendapatkan daftar kontainer yang aktif pada Swarm
def get_active_containers(service_name):
    active_containers = []
    try:
        service = client.services.get(service_name)
        for task in service.tasks():
            if task['Status']['State'] == 'running':
                container_id = task['ID']
                node_id = task['NodeID']
                node = client.nodes.get(node_id)
                node_name = node.attrs['Description']['Hostname']
                active_containers.append((container_id, node_name))
    except docker.errors.APIError as e:
        print(f"Error: {e}")
    return active_containers

# Fungsi untuk mendapatkan daftar node yang aktif pada Swarm
def get_active_nodes():
    active_nodes = []
    try:
        for node in client.nodes.list():
            if node.attrs['Status']['State'] == 'ready':
                node_name = node.attrs['Description']['Hostname']
                active_nodes.append(node_name)
    except docker.errors.APIError as e:
        print(f"Error: {e}")
    return active_nodes

# Fungsi untuk memantau perpindahan kontainer dan status node
def monitor_containers(service_name):
    previous_containers = get_active_containers(service_name)
    previous_nodes = get_active_nodes()
    downtime_start = None
    while True:
        try:
            time.sleep(5)  # Periksa setiap 5 detik
            current_containers = get_active_containers(service_name)
            current_nodes = get_active_nodes()
            # Periksa perpindahan kontainer
            for container_id, node_name in current_containers:
                previous_node = None
                for prev_container_id, prev_node_name in previous_containers:
                    if container_id == prev_container_id:
                        previous_node = prev_node_name
                        break
                if previous_node is None:
                    if downtime_start:
                        local_tz = pytz.timezone('Asia/Jakarta')  # Waktu Indonesia Barat (WIB)
                        local_time = datetime.now(local_tz).strftime('%Y-%m-%d %H:%M:%S')
                        print(f"Downtime selesai, container {container_id} baru saja dibuat di node {node_name} pada waktu {local_time}")
                        downtime_start = None
                    else:
                        print(f"Container {container_id} baru saja dibuat di node {node_name}")
                elif node_name != previous_node:
                    local_tz = pytz.timezone('Asia/Jakarta')  # Waktu Indonesia Barat (WIB)
                    local_time = datetime.now(local_tz).strftime('%Y-%m-%d %H:%M:%S')
                    print(f"Container {container_id} berpindah dari node {previous_node} ke node {node_name} pada waktu {local_time}")
            # Periksa node yang mati
            for node_name in previous_nodes:
                if node_name not in current_nodes:
                    local_tz = pytz.timezone('Asia/Jakarta')  # Waktu Indonesia Barat (WIB)
                    local_time = datetime.now(local_tz).strftime('%Y-%m-%d %H:%M:%S')
                    print(f"Node {node_name} mati pada waktu {local_time}")
                    downtime_start = time.time()  # Catat waktu node mati
            # Periksa node yang baru hidup
            for node_name in current_nodes:
                if node_name not in previous_nodes:
                    if downtime_start:
                        local_tz = pytz.timezone('Asia/Jakarta')  # Waktu Indonesia Barat (WIB)
                        local_time = datetime.now(local_tz).strftime('%Y-%m-%d %H:%M:%S')
                        print(f"Downtime selesai, node {node_name} kembali hidup pada waktu {local_time}")
                        downtime_start = None
                    else:
                        print(f"Node {node_name} baru saja kembali hidup")
            previous_containers = current_containers
            previous_nodes = current_nodes
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    service_name = "wordpress_stack_wordpress"
    monitor_containers(service_name)
