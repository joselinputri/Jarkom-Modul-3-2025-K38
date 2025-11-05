1. Node Erendis: Update Peta Utama (Forward Zone)
Ini untuk menambah CNAME (www) dan TXT (pesan rahasia).
a. Hentikan Server named Di terminal Erendis, tekan Ctrl + C untuk menghentikan named -g -4 yang lagi jalan.
b. Edit File Peta (db.K38.com)
```
nano /etc/bind/db.K38.com
```
c. Lakukan 3 Perubahan (SERIAL, CNAME, TXT) File-mu akan terlihat seperti ini (lihat bagian SERIAL dan 2 blok tambahan di bawah):
```
;
; BIND data file for K38.com
;
$TTL    604800
@       IN      SOA     ns1.K38.com. root.K38.com. (
                              2         ; Serial (NAIKKAN JADI 2!)
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
; === Name Servers (NS Records) ===
@       IN      NS      ns1.K38.com.
@       IN      NS      ns2.K38.com.

; === Alias (CNAME) ===
www     IN      CNAME   @

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

; === Pesan Rahasia (TXT) ===
elros     IN      TXT     "Cincin Sauron"
pharazon  IN      TXT     "Aliansi Terakhir"
```
2. 📍 Node Erendis: Buat Peta Terbalik (Reverse Zone / PTR)
Ini untuk melacak IP Erendis (...3.2) dan Amdir (...4.2)
a. Daftarkan Reverse Zone Buka file konfigurasi utama BIND:
```
nano /etc/bind/named.conf.local
```
Tambahkan 2 blok zone baru ini di bagian bawah (ini untuk jaringan 192.230.3.x dan 192.230.4.x):
```
// Reverse zone untuk jaringan Erendis (192.230.3.x)
zone "3.230.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.230.3";
};

// Reverse zone untuk jaringan Amdir (192.230.4.x)
zone "4.230.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.230.4";
};
```
b. Buat File Peta Terbalik Kita perlu membuat 2 file baru yang kita daftarkan di atas.
File untuk Jaringan Erendis (...3.x)
```
nano /etc/bind/db.192.230.3
```
Isi dengan ini (PTR record 2 menunjuk ke IP .2 yaitu Erendis):
```
$TTL    604800
@       IN      SOA     ns1.K38.com. root.K38.com. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.K38.com.
;
; === PTR Records ===
2       IN      PTR     ns1.K38.com. ; (192.230.3.2)
```
File untuk Jaringan Amdir (...4.x)
```
nano /etc/bind/db.192.230.4
```
Isi dengan ini (PTR record 2 menunjuk ke IP .2 yaitu Amdir):
```
$TTL    604800
@       IN      SOA     ns1.K38.com. root.K38.com. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.K38.com.
;
; === PTR Records ===
2       IN      PTR     ns2.K38.com. ; (192.230.4.2)
```
3. Node Erendis: Cek & Jalankan Ulang
a. Cek Semua Konfigurasi:
```
# Cek config utama
named-checkconf

# Cek peta utama (forward)
named-checkzone K38.com /etc/bind/db.K38.com

# Cek peta terbalik (reverse)
named-checkzone 3.230.192.in-addr.arpa /etc/bind/db.192.230.3
named-checkzone 4.230.192.in-addr.arpa /etc/bind/db.192.230.4
```
(Pastikan semuanya OK).
b. Jalankan Ulang Server:
```
named -g -4
```
4. 📍 Node Gilgalad: Verifikasi
Sekarang pindah ke terminal klien (seperti Gilgalad).
a. Tes CNAME (Alias www):
```
dig www.K38.com
```

b. Tes TXT (Pesan Rahasia):
```
dig elros.K38.com TXT
```

c. Tes PTR (Peta Terbalik):
```
# Tes IP Erendis
dig -x 192.230.3.2

# Tes IP Amdir
dig -x 192.230.4.2
```
















