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

