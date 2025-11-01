 # galadriel
#!/bin/bash
# Konfigurasi otomatis PHP Worker - Galadriel

echo "[1/6] Update & Install nginx + php-fpm..."
apt update -y
apt install -y nginx php8.4-fpm

echo "[2/6] Start services manually (no systemctl)..."
/etc/init.d/php8.4-fpm start
/etc/init.d/nginx start

echo "[3/6] Buat file index.php..."
mkdir -p /var/www/html
echo "<?php echo 'Halo dari Galadriel'; ?>" > /var/www/html/index.php

echo "[4/6] Konfigurasi nginx untuk port 8004..."
cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 8004;
    server_name galadriel.k38.com;  # ganti kxx dengan nama kelompokmu

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

echo "[5/6] Restart nginx..."
/etc/init.d/nginx restart

echo "[6/6] Tes koneksi lokal..."
curl -s http://localhost:8004 && echo -e "\n✅ Galadriel PHP server aktif di port 8004!"

# celebron
# 1. Update & install paket
apt update -y
apt install -y nginx php8.4-fpm

# 2. Start service manual (karena gak ada systemctl)
 /etc/init.d/php8.4-fpm start
 /etc/init.d/nginx start

# 3. Buat folder dan file web
mkdir -p /var/www/html
echo "<?php echo 'Halo dari Celeborn'; ?>" > /var/www/html/index.php

# 4. Konfigurasi nginx (port 8005 & domain celeborn.k38.com)
cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 8005;
    server_name celeborn.k38.com;

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# 5. Restart nginx secara manual
/etc/init.d/nginx restart

# 6. Tes koneksi lokal
curl -s http://localhost:8005 && echo -e "\n✅ Celeborn PHP server aktif di port 8005!"


# oropher
# 1. Install paket
apt update -y
apt install -y nginx php8.4-fpm

# 2. Start service manual
/etc/init.d/php8.4-fpm start
/etc/init.d/nginx start

# 3. Buat file index.php
mkdir -p /var/www/html
echo "<?php echo 'Halo dari Oropher'; ?>" > /var/www/html/index.php

# 4. Konfigurasi Nginx untuk port 8006
cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 8006;
    server_name oropher.k38.com;

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# 5. Restart Nginx
/etc/init.d/nginx restart

# 6. Tes koneksi lokal
curl -s http://localhost:8006 && echo -e "\n✅ Oropher PHP server aktif di port 8006!"

chmod +x /root/13.sh
bash /root/13.sh
