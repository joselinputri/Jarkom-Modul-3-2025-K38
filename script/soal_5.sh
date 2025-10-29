1. Update Peta Utama (Forward Zone)
#edit zone file
```
Update Peta Utama (Forward Zone)
```
#lakukan 3 perubahan
UPDATE SERIAL: Ini wajib agar Amdir mau menyalin. Ubah 1 menjadi 2.
TAMBAHKAN CNAME: Tambahkan www sebagai alias.
TAMBAHKAN TXT: Tambahkan pesan rahasia ke elros dan pharazon.
```
#maka akan terlihat seperti ini (bagian serial dan 2 blok tambahan)
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
; === Name Servers ===
@       IN      NS      ns1.K38.com.
@       IN      NS      ns2.K38.com.

; === Alias (CNAME) ===
www     IN      CNAME   @

; === A Records (Alamat IP) ===
; Name Servers
ns1     IN      A       192.230.3.2     ; IP Erendis (Master)
ns2     IN      A       192.230.4.2     ; IP Amdir (Slave)

; Host Records
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
2. Buat Peta Terbalik (Reverse Zone / PTR)
#daftarkan reverse zone
```
nano /etc/bind/named.conf.local
```
```
#Tambahkan 2 blok zone baru ini di bagian bawah (ini untuk jaringan 192.230.3.0/24 dan 192.230.4.0/24):
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
```
#Buat File Peta Terbalik
nano /etc/bind/db.192.230.3
```
```
#Isi dengan ini (PTR record 2 menunjuk ke IP .2 yaitu Erendis):
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
```
#File untuk Jaringan Amdir
nano /etc/bind/db.192.230.4
```
```
#Isi dengan ini (PTR record 2 menunjuk ke IP .2 yaitu Amdir):
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
3. Cek Konfigurasi & Restart
#Cek Semua Konfigurasi:(terminal erendis)
```
# Cek config utama
named-checkconf

# Cek peta utama (forward)
named-checkzone K38.com /etc/bind/db.K38.com

# Cek peta terbalik (reverse)
named-checkzone 3.230.192.in-addr.arpa /etc/bind/db.192.230.3
named-checkzone 4.230.192.in-addr.arpa /etc/bind/db.192.230.4
```
```
#restart bind9
/etc/init.d/bind9 restart
```
4. Verifikasi
#tes cname
```
dig www.K38.com
```
#tes txt
```
dig elros.K38.com TXT
```
#tes ptr
```
# Tes IP Erendis
dig -x 192.230.3.2

# Tes IP Amdir
dig -x 192.230.4.2
```

