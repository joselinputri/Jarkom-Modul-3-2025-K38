1. Konfigurasi Minastir (Proxy Server)
#Minastir(192.230.5.2):
```
# Pastikan cache paket Anda ter-update
apt update

# Install squid
apt install squid
```
#konfigurasi squid
```
nano /etc/squid/squid.conf
```
#Tambahkan ACL (Daftar Izin): Cari bagian acl ... (biasanya di sekitar baris acl CONNECT ...). Tambahkan blok ini sebelum http_access deny all:
```
# --- Tambahkan ACL untuk semua jaringan internal Anda ---
acl localnet src 192.230.1.0/24
acl localnet src 192.230.2.0/24
acl localnet src 192.230.3.0/24
acl localnet src 192.230.4.0/24
acl localnet src 192.230.5.0/24

# Izinkan akses dari jaringan tersebut
http_access allow localnet
# --- Akhir tambahan ---
```
#Aktifkan Mode Transparan: Cari baris http_port 3128. Ubah baris itu menjadi
```
# Squid defaultnya berjalan di port 3128
# Kita tambahkan 'transparent' di akhirnya
http_port 3128 transparent
```
#restart squid
```
/etc/init.d/squid restart
```
#untuk memastikan berjalan
```
/etc/init.d/squid status
```
2. Konfigurasi Durin (Router)
#Hapus Aturan NAT Lama
```
# -D berarti Delete. Hapus aturan lama.
iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```
#Buat Aturan NAT Baru (Hanya untuk Minastir)
```
iptables -t nat -A POSTROUTING -s 192.230.5.2 -o eth0 -j MASQUERADE
```
#Buat Aturan Redirect (PREROUTING)
```
# Trafik dari Jaringan 1 (eth1) -> belokkan ke Minastir
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j DNAT --to-destination 192.230.5.2:3128

# Trafik dari Jaringan 2 (eth2) -> belokkan ke Minastir
iptables -t nat -A PREROUTING -i eth2 -p tcp --dport 80 -j DNAT --to-destination 192.230.5.2:3128

# Trafik dari Jaringan 3 (eth3) -> belokkan ke Minastir
iptables -t nat -A PREROUTING -i eth3 -p tcp --dport 80 -j DNAT --to-destination 192.230.5.2:3128

# Trafik dari Jaringan 4 (eth4) -> belokkan ke Minastir
iptables -t nat -A PREROUTING -i eth4 -p tcp --dport 80 -j DNAT --to-destination 192.230.5.2:3128

# PENTING: Trafik dari Jaringan 5 (eth5) -> belokkan, KECUALI Minastir sendiri!
# (-s ! 192.230.5.2 artinya "source BUKAN 192.230.5.2")
iptables -t nat -A PREROUTING -i eth5 -s ! 192.230.5.2 -p tcp --dport 80 -j DNAT --to-destination 192.230.5.2:3128
```
3. Pengujian (di Klien)
#tes ping(harus gagal)
```
ping 8.8.8.8
```
#tes apt(harus berhasil)
```
apt update
```

