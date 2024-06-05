````markdown
# Instalasi K3s dengan Konfigurasi High Availability (HA)

Ini adalah panduan singkat untuk menginstal K3s dengan konfigurasi High Availability (HA) menggunakan skrip bash.

## Langkah-langkah

### 1. Instalasi Server Pertama (server1)

```bash
curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET sh -s - server \
    --cluster-init \
    --tls-san=192.168.122.61
```

### 2. Bergabungkan Server Kedua (server2) ke dalam Cluster

```bash
curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET sh -s - server \
    --server https://192.168.122.61:6443 \
    --tls-san=192.168.122.62
```

### 3. Bergabungkan Server Ketiga (server3) ke dalam Cluster

```bash
curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET sh -s - server \
    --server https://192.168.122.61:6443 \
    --tls-san=192.168.122.63
```

### 4. Periksa Status Cluster

```bash
kubectl get nodes
```

Setelah menyelesaikan langkah-langkah di atas, Anda akan memiliki konfigurasi control plane K3s yang memiliki tingkat ketersediaan yang tinggi. Sekarang Anda dapat menambahkan node agen ke dalam cluster dengan menggunakan perintah berikut:

### Tambahkan Node Agen ke dalam Cluster

```bash
curl -sfL https://get.k3s.io | K3S_TOKEN=SECRET sh -s - agent --server https://192.168.122.61:6443
```

Pastikan untuk mengganti `<ip or hostname of server>` dengan alamat IP atau hostname server Anda saat ini.

Jika Anda mengalami kesulitan atau memiliki pertanyaan, jangan ragu untuk bertanya!
```
