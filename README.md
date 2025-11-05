# Jarkom-Modul-3-2025-K38

## 👥 Anggota Kelompok

| Nama                     | NRP        |
| ------------------------ | ---------- |
| Ahmad Syauqi Reza        | 5027241085 |
| Putri Joselina Silitonga | 5027241116 |

## Deskripsi Laporan 📝

---

# Soal 1

Soal ini intinya adalah memberi akses internet sementara ke semua node (kecuali Durin).

Kita diminta untuk mengatur nameserver di semua 19 node itu (Minastir, Aldarion, Elendil, Gilgalad, dll.) biar nunjuk ke 192.168.122.1.

Tujuannya cuma satu: biar mereka bisa apt update dan nginstal paket-paket yang dibutuhin buat soal-soal berikutnya.

### Durin

```
nano /etc/network/interfaces
```

```
# Interface ke NAT/Internet (Dynamic)
auto eth0
iface eth0 inet dhcp

# Interface ke Switch1 (Static)
auto eth1
iface eth1 inet static
    address 192.230.1.1
    netmask 255.255.255.0

# Interface ke Switch2 (Static)
auto eth2
iface eth2 inet static
    address 192.230.2.1
    netmask 255.255.255.0

# Interface ke Switch5 (Static)
auto eth3
iface eth3 inet static
    address 192.230.3.1
    netmask 255.255.255.0

# Interface ke Switch6 (Static)
auto eth4
iface eth4 inet static
    address 192.230.4.1
    netmask 255.255.255.0

# Interface ke Switch7 (Static)
auto eth5
iface eth5 inet static
    address 192.230.5.1
    netmask 255.255.255.0

```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

restart network

```
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

### Allow forwarding dari internal ke internet

```
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth4 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth5 -o eth0 -j ACCEPT

# 5. Allow forwarding dari internet ke internal
iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth3 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth4 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth5 -j ACCEPT


```

Konfigurasi Node dengan IP Static

1. Minastir (Forward Proxy)
   konfigurasi ip

```
# 1. Atur IP address
ip addr add 192.230.5.2/24 dev eth0

# 2. Nyalakan interface
ip link set eth0 up

# 3. Atur gateway
ip route add default via 192.230.5.1
```

```
nano /etc/network/interfaces
```

```
auto eth0
iface eth0 inet static
    address 192.230.5.2  # sesuaikan dengan IP yang diberikan
    netmask 255.255.255.0
    gateway 192.230.5.1  # gateway menuju router
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

2. Aldarion (DHCP Server)

```
# 1. Atur IP address
ip addr add 192.230.4.3/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.4.1
```

```
nano /etc/network/interfaces
```

```
auto eth0
iface eth0 inet static
    address 192.230.4.3
    netmask 255.255.255.0
    gateway 192.230.4.1
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

3. Erendis (DNS Master)

```
# 1. Atur IP address
ip addr add 192.230.3.2/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.3.1
```

```
nano /etc/network/interfacesk
```

```
auto eth0
iface eth0 inet static
    address 192.230.3.2
    netmask 255.255.255.0
    gateway 192.230.3.1
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

4. Amdir (DNS Slave)

```
# 1. Atur IP address
ip addr add 192.230.3.3/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.3.1
```

```
nano /etc/network/interfaces
```

```
auto eth0
iface eth0 inet static
    address 192.230.3.3
    netmask 255.255.255.0
    gateway 192.230.3.1
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

5. Palantir (Database Server)

```
# 1. Atur IP address
ip addr add 192.230.4.5/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.4.1
```

```
nano /etc/network/interfaces
```

```
auto eth0
iface eth0 inet static
    address 192.230.4.5
    netmask 255.255.255.0
    gateway 192.230.4.1
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

6. Narvi (Database Slave)

```
# 1. Atur IP address
ip addr add 192.230.4.4/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.4.1
```

```
nano /etc/network/interfaces
```

```
auto eth0
iface eth0 inet static
    address 192.230.4.4
    netmask 255.255.255.0
    gateway 192.230.4.1
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

7. Elros (Load Balancer Laravel)

```
# 1. Atur IP address
ip addr add 192.230.1.5/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.1.1
```

```
nano /etc/network/interfaces
```

```
auto eth0
iface eth0 inet static
    address 192.230.1.5
    netmask 255.255.255.0
    gateway 192.230.1.1
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

8. Pharazon (Load Balancer PHP)

```
# 1. Atur IP address
ip addr add 192.230.2.7/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.2.1
```

```
nano /etc/network/interfaces
```

```
auto eth0
iface eth0 inet static
    address 192.230.2.7
    netmask 255.255.255.0
    gateway 192.230.2.1
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

9. Elendil (Laravel Worker-1)

```
# 1. Atur IP address
ip addr add 192.230.1.2/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.1.1
```

```
nano /etc/network/interfaces
```

```
auto eth0
iface eth0 inet static
    address 192.230.1.2
    netmask 255.255.255.0
    gateway 192.230.1.1
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

10. Isildur (Laravel Worker-2)

```
# 1. Atur IP address
ip addr add 192.230.1.3/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.1.1
```

```
# 1. Atur IP address
ip addr add 192.230.1.3/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.1.1
```

```
nano /etc/network/interfaces
```

```
auto eth0
iface eth0 inet static
    address 192.230.1.3
    netmask 255.255.255.0
    gateway 192.230.1.1
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

11. Anarion (Laravel Worker-3)

```
# 1. Atur IP address
ip addr add 192.230.1.4/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.1.1
```

```
nano /etc/network/interfaces
```

```
auto eth0
iface eth0 inet static
    address 192.230.1.4
    netmask 255.255.255.0
    gateway 192.230.1.1
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

12. Galadriel (PHP Worker-1)

```
# 1. Atur IP address
ip addr add 192.230.2.2/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.2.1
```

```
nano /etc/network/interfaces
```

```
auto eth0
iface eth0 inet static
    address 192.230.2.2
    netmask 255.255.255.0
    gateway 192.230.2.1
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

13. Celeborn (PHP Worker-2)

```
# 1. Atur IP address
ip addr add 192.230.2.3/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.2.1
```

```
nano /etc/network/interfaces
```

```
auto eth0
iface eth0 inet static
    address 192.230.2.3
    netmask 255.255.255.0
    gateway 192.230.2.1
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

14. Oropher (PHP Worker-3)

```
# 1. Atur IP address
ip addr add 192.230.2.4/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.2.1
```

```
nano /etc/network/interfaces
```

```
auto eth0
iface eth0 inet static
    address 192.230.2.4
    netmask 255.255.255.0
    gateway 192.230.2.1
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

15. Miriel (Client-Static-1)

```
# 1. Atur IP address
ip addr add 192.230.1.6/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.1.1
```

```
nano /etc/network/interfaces
```

```
auto eth0
iface eth0 inet static
    address 192.230.1.6
    netmask 255.255.255.0
    gateway 192.230.1.1
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

16. Celebrimbor (Client-Static-2)

```
# 1. Atur IP address
ip addr add 192.230.2.6/24 dev eth0
# 2. Nyalakan interface
ip link set eth0 up
# 3. Atur gateway
ip route add default via 192.230.2.1
```

```
nano /etc/network/interfaces
```

```
auto eth0
iface eth0 inet static
    address 192.230.2.6
    netmask 255.255.255.0
    gateway 192.230.2.1
```

```
echo "nameserver 192.168.122.1" > /etc/resolv.conf

```

Client Dynamic & Fixed address

1. Gilgalad (Client-Dynamic-1)

```

# 1. Atur IP SEMENTARA

ip addr add 192.230.2.5/24 dev eth0
ip link set eth0 up
ip route add default via 192.230.2.1

# 2. Atur DNS

echo "nameserver 192.168.122.1" > /etc/resolv.conf

```

2. Amandil (Client-Dynamic-2)

```

# 1. Atur IP SEMENTARA

ip addr add 192.230.1.7/24 dev eth0
ip link set eth0 up
ip route add default via 192.230.1.1

# 2. Atur DNS
echo "nameserver 192.168.122.1" > /etc/resolv.conf

```

3. Khamul (Cilent-Fixed-Address)

```

# 1. Atur IP SEMENTARA

ip addr add 192.230.3.3/24 dev eth0
ip link set eth0 up
ip route add default via 192.230.3.1

# 2. Atur DNS

echo "nameserver 192.168.122.1" > /etc/resolv.conf

```

# Soal 2

Pada soal ini, kita diminta untuk mengatur DHCP Server dan DHCP Relay.

Aldarion (DHCP Server): Kita harus konfigurasi dia buat memberikan IP:

Jaringan 1 (Manusia): Memberikan IP di dua rentang (.1.6 - .1.34 dan .1.68 - .1.94).

Jaringan 2 (Peri): Memberikan IP di dua rentang (.2.35 - .2.67 dan .2.96 - .2.121).

Khamul (Jaringan 3): Memberikan IP tetap (fixed-address) di .3.95 (berdasarkan MAC address-nya).

Durin (DHCP Relay): Kita harus konfigurasi dia biar "teriakan" minta IP dari Jaringan 1, 2, dan 3 bisa diteruskan ke Aldarion.

1. Konfigurasi Aldarion (DHCP Server)

```
apt update
apt install isc-dhcp-server
```

#konfigurasi interface

```
nano /etc/default/isc-dhcp-server
```

#cari baris INTERFACESv4=”” dan ubah menjadi

```
INTERFACESv4="eth0"
```

#konfigurasi /etc/dhcp/dhcpd.conf

```
nano /etc/dhcp/dhcpd.conf
```

```
# --- Opsi Global ---
option domain-name "middle-earth.local";
option domain-name-servers 192.230.3.2, 192.230.4.2, 8.8.8.8;

default-lease-time 600;
max-lease-time 7200;

# Server ini adalah server DHCP resmi untuk jaringan lokal
authoritative;

# --- Jaringan 1: Keluarga Manusia (via Durin eth1) ---
subnet 192.230.1.0 netmask 255.255.255.0 {
    option routers 192.230.1.1; # Gateway (IP Durin)

    # Rentang 1
    range 192.230.1.6 192.230.1.34;
    # Rentang 2
    range 192.230.1.68 192.230.1.94;
}

# --- Jaringan 2: Keluarga Peri (via Durin eth2) ---
subnet 192.230.2.0 netmask 255.255.255.0 {
    option routers 192.230.2.1; # Gateway (IP Durin)

    # Rentang 1
    range 192.230.2.35 192.230.2.67;
    # Rentang 2
    range 192.230.2.96 192.230.2.121;
}

# --- Jaringan 3: Khamul (via Durin eth3) ---
subnet 192.230.3.0 netmask 255.255.255.0 {
    option routers 192.230.3.1; # Gateway (IP Durin)

    # Alokasi IP Tetap untuk Khamul
    host Khamul {
        hardware ethernet <MAC_ADDRESS_KHAMUL>;
        fixed-address 192.230.3.95;
    }
}

# --- Jaringan 4: Jaringan Aldarion sendiri (via Durin eth4) ---
# (Tidak ada rentang, hanya didefinisikan)
subnet 192.230.4.0 netmask 255.255.255.0 {
    option routers 192.230.4.1;
}
```

#cari MAC address Khamul
Pergi ke terminal Khamul.
Jalankan perintah: ip a
Cari eth0 dan catat alamat di sebelah link/ether. 02:42:fa:25:05:00
Kembali ke Aldarion dan masukkan MAC address itu ke file dhcpd.conf.
#Restart DHCP Server

```
/etc/init.d/isc-dhcp-server restart
```

2. Konfigurasi Durin (DHCP Relay)
   #instalasi Relay

```
apt update
apt install isc-dhcp-relay
```

#konfigurasi relay

```
nano /etc/default/isc-dhcp-relay
```

#ubah isinya menjadi

```
# Alamat IP Aldarion (DHCP Server)
SERVERS="192.230.4.3"

# Interface yang menghadap klien (Manusia, Peri, Khamul)
INTERFACES="eth1 eth2 eth3 eth4"
```

#restart dhcp relay

```
/etc/init.d/isc-dhcp-relay restart
```

3. Pengujian (node klien)
   #Di terminal Gilgalad (juga Amandil dan Khamul):

```
nano /etc/network/interfaces
```

#Hapus semua konfigurasi statis dan buat isinya menjadi:

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
```

#Simpan file itu, lalu jalankan DHCP client:

```
# 1. Download daftar paket
apt update
# 2. Instal DHCP client
apt install isc-dhcp-client
dhclient eth0
```

#verifikasi IP

```
ip a
```

#Gilgalad harus mendapat IP di rentang 192.230.2.x.
#Amandil harus mendapat IP di rentang 192.230.1.x.
#Khamul harus mendapat IP tepat 192.230.3.95.
