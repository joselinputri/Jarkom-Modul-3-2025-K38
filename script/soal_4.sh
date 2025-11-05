```
# Di terminal Durin
# Hapus semua aturan pembelokan (PREROUTING)
iptables -t nat -F PREROUTING
```
## Konfigurasi Erendis (Master Server)
Di terminal Erendis (192.230.3.2):
a. Instal BIND9 (Jika Hilang)
```
apt update
apt install bind9 dnsutils -y
```
b. Konfigurasi Opsi (named.conf.options)
```
nano /etc/bind/named.conf.options
```
Isi file ini seperti ini:

```
// Buat daftar izin untuk semua jaringan internal kita
acl "internal-nets" {
    192.230.1.0/24;
    192.230.2.0/24;
    192.230.3.0/24;
    192.230.4.0/24;
    192.230.5.0/24;
    localhost;
    localnets;
};

options {
    directory "/var/cache/bind";
    
    // Izinkan query & rekursi dari jaringan internal
    allow-query { internal-nets; };
    allow-recursion { internal-nets; };
    recursion yes;

    // Kirim query yang tidak diketahui ke DNS Google
    forwarders {
        8.8.8.8;
        8.8.4.4;
    };

    dnssec-validation auto;
    listen-on { any; };
    listen-on-v6 { none; }; // Paksa IPv4
};
```
c. Daftarkan Peta (Zone) Baru (named.conf.local)
```
nano /etc/bind/named.conf.local
```
Tambahkan ini di bagian bawah file:
```
// Zona utama K38.com
zone "K38.com" {
    type master;
    file "/etc/bind/db.K38.com";  // File peta (zone file) kita
    allow-transfer { 192.230.4.2; }; // Izinkan Amdir (IP Slave) menyalin
};
```
d. Buat File Peta (db.K38.com).
```
nano /etc/bind/db.K38.com
```
Isi dengan ini (ganti K38 dan pastikan IP-nya benar):
```
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
; === Name Servers (NS Records) ===
@       IN      NS      ns1.K38.com.
@       IN      NS      ns2.K38.com.

; === Name Server IPs (A Records) ===
ns1     IN      A       192.230.3.2     ; IP Erendis (Master)
ns2     IN      A       192.230.4.2     ; IP Amdir (Slave)

; === Host Records (A Records) ===
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
e. Cek & Jalankan
```
# Cek config
named-checkconf

# Cek file peta (ganti K38)
named-checkzone K38.com /etc/bind/db.K38.com

named -g -4
```
3. Konfigurasi Amdir (Slave Server)
Di terminal Amdir (192.230.4.2):
a. Instal BIND9 (Jika Hilang)
```
apt update
apt install bind9 dnsutils -y
```
b. Konfigurasi Opsi (named.conf.options).
c. Daftarkan Peta (Zone).
```
nano /etc/bind/named.conf.local
```
Tambahkan ini di bagian bawah file:
```
// Zona K38.com (disalin dari Master)
zone "K38.com" {
    type slave;
    file "db.K38.com";          // BIND akan otomatis menyimpan salinannya
    masters { 192.230.3.2; };  // Alamat IP Erendis (Master)
};
```
d. Cek & Jalankan
```
# Cek config
named-checkconf

# Jalankan (karena kita tahu /etc/init.d/ tidak ada)
named -g -4
```
4. Update Klien (via DHCP Aldarion)
Di terminal Aldarion (192.230.4.3):
a. Edit Konfigurasi DHCP
```
nano /etc/dhcp/dhcpd.conf
```
b. Ubah Opsi domain-name-servers Di bagian atas (Opsi Global)
```
option domain-name-servers 192.230.3.2, 192.230.4.2;
```
c. Restart DHCP Server
```
/etc/init.d/isc-dhcp-server restart
```
5. Verifikasi (di Klien)
Pindah ke Gilgalad (atau klien dinamis lainnya).
a. Minta IP & DNS Baru
```
dhclient -v eth0
```

b. Cek File DNS
```
cat /etc/resolv.conf
```
(Outputnya harus nameserver 192.230.3.2 dan nameserver 192.230.4.2).

c. Tes dig
```
# Tes internal (ganti K38)
dig elendil.K38.com

# Tes eksternal (rekursif)
dig google.com
```




