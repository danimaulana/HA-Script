#pra running
#sudo apt install python3-pip
#pip install paramiko

import paramiko
import random
import time
from datetime import datetime, timedelta

# Rentang IP
IPS = ["192.168.122.62", "192.168.122.63", "192.168.122.64", "192.168.122.65"]

# Durasi pengujian (1 jam = 3600 detik)
END_TIME = datetime.now() + timedelta(hours=1)

# Fungsi untuk mencetak waktu dan status node
def log_status(node_ip, action):
    print(f"{datetime.now()} - Node {node_ip} is {action}")

# Fungsi untuk mematikan dan menyalakan kembali node
def toggle_node(ip, ssh_client):
    log_status(ip, "shutting down")
    ssh_client.connect(ip, username='ubuntu', password='ubuntu')
    ssh_client.exec_command("sudo shutdown now")  # Gunakan sudo jika diperlukan
    ssh_client.close()

    # Tunggu selama 3 menit
    time.sleep(180)

    log_status(ip, "rebooting")
    ssh_client.connect(ip, username='ubuntu', password='ubuntu')
    ssh_client.exec_command("sudo nohup reboot &")  # Gunakan sudo jika diperlukan
    ssh_client.close()

# Fungsi utama untuk menjalankan pengujian
def main():
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    start_time = datetime.now()
    print(f"Program started at {start_time}")
    
    # Loop sampai waktu pengujian berakhir
    while datetime.now() < END_TIME:
        # Matikan dan nyalakan kembali setiap node dalam rentang IP
        for ip in IPS:
            toggle_node(ip, ssh_client)
            time.sleep(3)  # Tunggu 3 detik sebelum mematikan node berikutnya
    
    end_time = datetime.now()
    print(f"Program ended at {end_time}")

# Menjalankan skrip
if __name__ == "__main__":
    main()
