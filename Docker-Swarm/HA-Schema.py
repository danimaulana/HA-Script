import subprocess
import threading
import time
from datetime import datetime

def get_vm_status(vm_name):
    command = f"virsh domstate {vm_name}"
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return result.stdout.strip()

def shutdown_vm(vm_name):
    command = f"virsh shutdown {vm_name}"
    subprocess.run(command, shell=True)

def start_vm(vm_name):
    command = f"virsh start {vm_name}"
    subprocess.run(command, shell=True)

def manage_vms():
    vms = ["Master2-Docker", "Master3-Docker"]
    index = 0
    while True:
        start_time = datetime.now()
        vm = vms[index % len(vms)]
        # Matikan VM
        shutdown_vm(vm)
        print(f"[{start_time.strftime('%H:%M:%S')}] Mematikan {vm}...")
        time.sleep(2 * 60)  # Tunggu 2 menit

        # Periksa status VM setelah dimatikan
        status = get_vm_status(vm)
        print(f"[{datetime.now().strftime('%H:%M:%S')}] Status {vm} setelah dimatikan: {status}")

        # Nyalakan VM
        start_vm(vm)
        print(f"[{datetime.now().strftime('%H:%M:%S')}] Menyalakan {vm}...")
        time.sleep(2 * 60)  # Tunggu 2 menit

        # Periksa status VM setelah dinyalakan
        status = get_vm_status(vm)
        print(f"[{datetime.now().strftime('%H:%M:%S')}] Status {vm} setelah dinyalakan: {status}")

        index += 1

if __name__ == "__main__":
    threading.Thread(target=manage_vms).start()
