# Load Balancer (Elros)
# Di Elros (192.230.5.20):
# Setup Dasar
# Set DNS
cat << EOF > /etc/resolv.conf
search K38.com
nameserver 192.230.3.10
nameserver 192.230.4.13
nameserver 192.168.122.1
EOF

# Set Proxy
export http_proxy="http://192.230.5.10:3128"
export https_proxy="http://192.230.5.10:3128"
echo 'Acquire::http::Proxy "http://192.230.5.10:3128/";' > /etc/apt/apt.conf.d/01proxy

# Install Nginx
apt update
apt install nginx -y

# Configure Load Balancer
cat << 'EOF' > /etc/nginx/sites-available/elros-lb
# Upstream untuk Laravel Workers (Round Robin)
upstream kesatria_numenor {
    server 192.230.1.10:8001;  # Elendil
    server 192.230.1.11:8002;  # Isildur
    server 192.230.1.12:8003;  # Anarion
}

server {
    listen 80;
    server_name elros.K38.com;

    location / {
        proxy_pass http://kesatria_numenor;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    access_log /var/log/nginx/elros_access.log;
    error_log /var/log/nginx/elros_error.log;
}
EOF

# Enable site
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/elros-lb /etc/nginx/sites-enabled/

# Test & Start
nginx -t
pkill nginx
nginx

# Test Load Balancer
# Test beberapa kali untuk lihat round robin
for i in {1..9}; do
    echo "Request $i:"
    curl -s http://elros.K38.com | head -5
    echo "---"
done

# Testing dari Client:
# Test dengan lynx
lynx http://elros.K38.com

# Test API
curl http://elros.K38.com/api/airing

# Test Round Robin (jalankan beberapa kali)
for i in {1..10}; do
    echo "Request $i:"
    curl -s http://elros.K38.com/api/airing | head -3
done