## Bagian 1: Konfigurasi Minastir (DNS Filter)

Di terminal Minastir (192.230.5.2):

1. Instal BIND9

```
apt update
apt install bind9 dnsutils
```

2. Konfigurasi named.conf.options

```
nano /etc/bind/named.conf.options
```

Hapus semua isinya dan ganti dengan ini:

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

    // Izinkan query dari jaringan internal
    allow-query { internal-nets; };

    // Izinkan recursive query dari jaringan internal
    allow-recursion { internal-nets; };
    recursion yes;

    // Kirim query yang tidak diketahui ke DNS Google
    forwarders {
        8.8.8.8;
        8.8.4.4;
    };

    dnssec-validation auto;

    // Dengarkan di semua interface
    listen-on { any; };
    listen-on-v6 { any; };
};
```

3. Jalankan BIND9 (Manual)

```
named-checkconf

# Jalankan servernya
# Pakai -4 untuk menghindari error IPv6
named -g -4
```

## Bagian 2: Konfigurasi Durin (Router & Polisi)

Di terminal Durin:

1. Aktifkan IP Forwarding

```
echo 1 > /proc/sys/net/ipv4/ip_forward
```

2. Jalankan DHCP Relay (Soal 2)

```
dhcrelay -i eth1 -i eth2 -i eth3 -i eth4 192.230.4.3 &
```

3. Terapkan Aturan iptables (Soal 3 Baru)
   A. Aturan NAT (Izinkan SEMUA ke Internet).

```
iptables -t nat -A POSTROUTING -s 192.230.1.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.230.2.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.230.3.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.230.4.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.230.5.0/24 -o eth0 -j MASQUERADE
```

B. Aturan Redirect DNS (Belokkan ke Minastir).

```
# --- Jaringan 1 (eth1) ---
iptables -t nat -A PREROUTING -i eth1 -p udp --dport 53 -j DNAT --to-destination 192.230.5.2
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 53 -j DNAT --to-destination 192.230.5.2

# --- Jaringan 2 (eth2) ---
iptables -t nat -A PREROUTING -i eth2 -p udp --dport 53 -j DNAT --to-destination 192.230.5.2
iptables -t nat -A PREROUTING -i eth2 -p tcp --dport 53 -j DNAT --to-destination 192.230.5.2

# --- Jaringan 3 (eth3) ---
iptables -t nat -A PREROUTING -i eth3 -p udp --dport 53 -j DNAT --to-destination 192.230.5.2
iptables -t nat -A PREROUTING -i eth3 -p tcp --dport 53 -j DNAT --to-destination 192.230.5.2

# --- Jaringan 4 (eth4) ---
iptables -t nat -A PREROUTING -i eth4 -p udp --dport 53 -j DNAT --to-destination 192.230.5.2
iptables -t nat -A PREROUTING -i eth4 -p tcp --dport 53 -j DNAT --to-destination 192.230.5.2

# === UDP ===
# ATURAN 1: Izinkan Minastir (192.230.5.2) lewat tanpa dibelokkan
iptables -t nat -A PREROUTING -i eth5 -s 192.230.5.2 -p udp --dport 53 -j RETURN

# ATURAN 2: Belokkan semua DNS (UDP) lainnya
iptables -t nat -A PREROUTING -i eth5 -p udp --dport 53 -j DNAT --to-destination 192.230.5.2

# === TCP ===
# ATURAN 1: Izinkan Minastir (192.230.5.2) lewat tanpa dibelokkan
iptables -t nat -A PREROUTING -i eth5 -s 192.230.5.2 -p tcp --dport 53 -j RETURN

# ATURAN 2: Belokkan semua DNS (TCP) lainnya
iptables -t nat -A PREROUTING -i eth5 -p tcp --dport 53 -j DNAT --to-destination 192.230.5.2
```

C. Aturan Firewall FORWARD Kita harus izinkan paketnya melintas.

```
# Izinkan SEMUA internal ke internet
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth4 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth5 -o eth0 -j ACCEPT

# Izinkan BALASAN dari internet
iptables -A FORWARD -i eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

Bagian 3: Pengujian (di Klien)
Pindah ke Gilgalad (atau klien lain).
Dapatkan IP:
```
dhclient -v eth0

```
Tes Ping (Harus BERHASIL)
```

ping 8.8.8.8

```

Tes DNS (Pembelokan).
```

cat /etc/resolv.conf

```

```

dig google.com

```






```
