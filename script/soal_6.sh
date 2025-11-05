Konfigurasi di Aldarion
Di terminal Aldarion (192.230.4.3):
1. Edit File dhcpd.conf
```
nano /etc/dhcp/dhcpd.conf
```
2. Lakukan 3 Perubahan
A. Ubah max-lease-time (Global): Di bagian atas file (Opsi Global), cari max-lease-time dan ubah nilainya menjadi 3600.
```
# --- Opsi Global ---
...
default-lease-time 600;  # Biarkan ini atau hapus
max-lease-time 3600;     # <-- UBAH INI (dari 7200)
...
```
B. Tambahkan Waktu di Subnet Manusia (Jaringan 1): Cari blok subnet 192.230.1.0 dan tambahkan default-lease-time 1800; di dalamnya.

```
# --- Jaringan 1: Keluarga Manusia (via Durin eth1) ---
subnet 192.230.1.0 netmask 255.255.255.0 {
    option routers 192.230.1.1;
    default-lease-time 1800; # <-- TAMBAHKAN INI (1800 detik)
    
    # Rentang 1
    range 192.230.1.6 192.230.1.34;
    # Rentang 2
    range 192.230.1.68 192.230.1.94;
}
```
C. Tambahkan Waktu di Subnet Peri (Jaringan 2): Cari blok subnet 192.230.2.0 dan tambahkan default-lease-time 600;.
```
# --- Jaringan 2: Keluarga Peri (via Durin eth2) ---
subnet 192.230.2.0 netmask 255.255.255.0 {
    option routers 192.230.2.1;
    default-lease-time 600; # <-- TAMBAHKAN INI (600 detik)
    
    # Rentang 1
    range 192.230.2.35 192.230.2.67;
    # Rentang 2
    range 192.230.2.96 192.230.2.121;
}
```
3. Restart DHCP Server
Agar konfigurasi baru terbaca, restart layanannya (ingat, di image kamu, kita pakai /etc/init.d/):
```
/etc/init.d/isc-dhcp-server restart
```
