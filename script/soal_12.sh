no 12
#!/bin/bash
# ==============================
# UNIVERSAL PHP WORKER SETUP v2
# ==============================

NODE_NAME=$(hostname)
echo "[$NODE_NAME] 🚀 Memulai setup PHP Worker..."

# ===== FIX DNS =====
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# ===== Update & install dependency =====
apt-get update -y
apt-get install -y nginx php php-fpm curl

# ===== Deteksi versi PHP aktif =====
PHP_VERSION=$(php -v 2>/dev/null | head -n1 | awk '{print $2}' | cut -d'.' -f1,2)
if [ -z "$PHP_VERSION" ]; then
  PHP_VERSION=$(ls /run/php/ | grep fpm.sock | sed 's/php\(.*\)-fpm.sock/\1/' | head -n1)
fi
echo "[$NODE_NAME] ✅ Detected PHP version: $PHP_VERSION"

# ===== Pastikan direktori web ada =====
mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# ===== Buat halaman PHP unik =====
echo "<?php echo 'Halo, saya $NODE_NAME!'; ?>" > /var/www/html/index.php

# ===== Perbaiki konfigurasi Nginx =====
cat > /etc/nginx/sites-available/default << EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.php index.html index.htm;

    server_name _;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php$PHP_VERSION-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# ===== Tes konfigurasi Nginx =====
if ! nginx -t; then
    echo "[$NODE_NAME] ❌ Nginx configuration error! Periksa file default."
    exit 1
fi

# ===== Restart PHP-FPM =====
echo "[$NODE_NAME] 🔄 Restart PHP-FPM..."
pkill -f php-fpm || true
service php$PHP_VERSION-fpm restart 2>/dev/null || /usr/sbin/php-fpm$PHP_VERSION -D

# ===== Restart Nginx =====
echo "[$NODE_NAME] 🔄 Restart Nginx..."
service nginx restart 2>/dev/null || /usr/sbin/nginx -s reload

# ===== Tes koneksi lokal =====
sleep 2
RESULT=$(curl -s http://localhost)
if [[ "$RESULT" == *"Halo, saya"* ]]; then
    echo "[$NODE_NAME] ✅ Web server aktif! Output:"
    echo "$RESULT"
else
    echo "[$NODE_NAME] ⚠️ Gagal menampilkan halaman PHP. Cek log Nginx/PHP-FPM."
fi

echo "[$NODE_NAME] 🎉 Setup selesai!"

 di setiap node : 
chmod +x /root/12.sh
bash /root/12.sh

curl http://192.230.2.3   # Galadriel
curl http://192.230.2.4   # Celeborn
curl http://192.230.2.5   # Oropher



