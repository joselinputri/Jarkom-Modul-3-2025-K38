# celebrimor 
#!/bin/bash
set -e

echo "=== SETUP ==="
ip addr flush dev eth0 || true
ip addr add 192.230.2.6/24 dev eth0
ip link set eth0 up
ip route add default via 192.230.2.1 || true
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update -y && apt install -y apache2-utils curl
grep -q "pharazon.k38.com" /etc/hosts || echo "192.230.2.7 pharazon.k38.com" >> /etc/hosts

echo -e "\n=== PHASE 1: Semua Worker Hidup ==="
echo "Test manual:"
for i in {1..15}; do curl -s -u noldor:silvan http://pharazon.k38.com/; echo "---"; done
echo -e "\nBenchmark:"
ab -n 1000 -c 50 -A noldor:silvan http://pharazon.k38.com/

echo -e "\n[!] Stop nginx di Galadriel: service nginx stop"
read -p "Tekan ENTER..."

echo -e "\n=== PHASE 2: Galadriel Down ==="
echo "Test manual:"
for i in {1..15}; do curl -s -u noldor:silvan http://pharazon.k38.com/; echo "---"; done
echo -e "\nBenchmark:"
ab -n 1000 -c 50 -A noldor:silvan http://pharazon.k38.com/

echo -e "\n[!] Cek log di Pharazon: tail -n 50 /var/log/nginx/error.log"
read -p "Screenshot, tekan ENTER..."

echo -e "\n[!] Start nginx di Galadriel: service nginx start"
read -p "Tekan ENTER..."

echo -e "\n=== PHASE 3: Recovery ==="
for i in {1..15}; do curl -s -u noldor:silvan http://pharazon.k38.com/; echo "---"; done

echo -e "\n=== SELESAI ==="

chmod +x /root/17.sh
bash /root/17.sh

