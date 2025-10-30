Durin
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
# 4. Allow forwarding dari internal ke internet
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
