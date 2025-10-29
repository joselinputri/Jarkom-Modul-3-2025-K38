konfigurasi di aldarion
1. edit file dhcpd.conf
```
nano /etc/dhcp/dhcpd.conf
```
2. lakukan 3 perubahan
```
# --- Opsi Global ---
...
default-lease-time 600;  # Biarkan ini atau hapus
max-lease-time 3600;     # <-- UBAH INI (dari 7200)
...
```
#Tambahkan Waktu di Subnet Manusia (Jaringan 1): Cari blok subnet 192.230.1.0 dan tambahkan default-lease-time 1800; di dalamnya.
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
#restart dhcp server
```
/etc/init.d/isc-dhcp-server restart
```
