# Testing Individual Workers
# Di Client (Miriel, Gilgalad, atau Amandil):
# Set DNS
cat << EOF > /etc/resolv.conf
search K38.com
nameserver 192.230.3.10
nameserver 192.230.4.13
nameserver 192.168.122.1
EOF

# Install lynx jika belum ada
export http_proxy="http://192.230.5.10:3128"
export https_proxy="http://192.230.5.10:3128"
apt update
apt install lynx curl -y

# Test Elendil:
# Test homepage dengan lynx
lynx -dump http://elendil.K38.com:8001

# Test API
curl http://elendil.K38.com:8001/api/airing

# Test Isildur:
# Test homepage dengan lynx
lynx -dump http://isildur.K38.com:8002

# Test API
curl http://isildur.K38.com:8002/api/airing

# Test Anarion:
# Test homepage dengan lynx
lynx -dump http://anarion.K38.com:8003

# Test API
curl http://anarion.K38.com:8003/api/airing