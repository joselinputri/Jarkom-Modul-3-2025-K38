1. Instalasi Bind9

```
# Pastikan kamu punya koneksi (Soal 1-3 harus beres)
apt update

# Install BIND9 (server DNS) dan dnsutils (untuk tes 'dig')
apt install bind9 dnsutils
```

2. Konfigurasi Erendis (Master Server)

#Definisikan Zone (di named.conf.local)
```
nano /etc/bind/named.conf.local
```
```
// Zona K38.com
zone "K38.com" {
    type master;
    file "/etc/bind/db.K38.com";  // File peta (zone file) kita
    allow-transfer { 192.230.4.2; }; // Izinkan Amdir (IP Slave) menyalin
};

```
#Buat Zone File (Peta Sebenarnya)
```
#copy file db.local
cp /etc/bind/db.local /etc/bind/db.K38.com
```
```
#edit file
nano /etc/bind/db.K38.com
```
```
#Hapus semua isinya dan ganti dengan ini. pastikan xxxx>.com< dan IP-nya sudah benar
;
; BIND data file for K38.com
;
$TTL    604800
@       IN      SOA     ns1.K38.com. root.K38.com. (
                              1         ; Serial (PENTING!)
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
; === Name Servers ===
@       IN      NS      ns1.K38.com.
@       IN      NS      ns2.K38.com.

; === A Records (Alamat IP) ===
; Name Servers
ns1     IN      A       192.230.3.2     ; IP Erendis (Master)
ns2     IN      A       192.230.4.2     ; IP Amdir (Slave)

; Host Records (sesuai soal)
palantir  IN      A       192.230.4.5
elros     IN      A       192.230.1.5
pharazon  IN      A       192.230.4.6
elendil   IN      A       192.230.1.2
isildur   IN      A       192.230.1.3
anarion   IN      A       192.230.1.4
galadriel IN      A       192.230.2.3
celeborn  IN      A       192.230.2.4
oropher   IN      A       192.230.2.5
```
#cek konfigurasi & restart
```
named-checkconf
```
```
#cek file zone (peta)
named-checkzone K38.com /etc/bind/db.K38.com
```
```
#restart Bind9
/etc/init.d/bind9 restart
```
3. Konfigurasi Amdir (Slave Server)
#Definisikan zone (di named.conf.lodal)
```
nano /etc/bind/named.conf.local
```
```
// Zona K38.com (disalin dari Master)
zone "K38.com" {
    type slave;
    file "db.K38.com";              // BIND akan otomatis menyimpan salinannya
    masters { 192.230.3.2; };      // Alamat IP Erendis (Master)
};
```
#cek & restart
```
named-checkconf
```
```
/etc/init.d/bind9 restart
```
4. Mengatur Klien (Resolver)
#klien statis(misal elendil)
```
# Di Elendil, Minastir, Palantir, dll.
nano /etc/resolv.conf
```
```
#Isinya harus seperti ini (hapus nameserver 192.168.122.1):
search K38.com
nameserver 192.230.3.2  ; IP Erendis (Master)
nameserver 192.230.4.2  ; IP Amdir (Slave)
```
#klien dinamis (update di aldarion)
```
nano /etc/dhcp/dhcpd.conf
```
```
#Cari baris option domain-name-servers ... dan ubah menjadi:
option domain-name-servers 192.230.3.2, 192.230.4.2;
```
```
/etc/init.d/isc-dhcp-server restart
```
```
dhclient -v eth0
```
5. verifikasi
#Pindah ke node klien misal elendil atau gilgalad
```
# Tes ping nama pendek (harus bisa karena 'search')
ping elendil

# Tes pakai 'dig'
dig palantir.K38.com
```

