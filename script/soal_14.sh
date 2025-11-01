# galadriel

janlup nano /etc/hosts di setiap klien dan mirial
192.230.2.3  galadriel.k38.com
192.230.2.4  celeborn.k38.com
192.230.2.5  oropher.k38.com

#!/bin/bash
# ===========================================
# Konfigurasi PHP Worker 1 - Galadriel
# ===========================================

echo "[1/8] Update Repository..."
apt update -y

echo "[2/8] Install Nginx, PHP, dan utilitas..."
apt install nginx php8.4-fpm php8.4-cli php8.4-common php8.4-mysql apache2-utils -y

echo "[3/8] Pastikan PHP-FPM aktif..."
systemctl enable php8.4-fpm
systemctl restart php8.4-fpm

echo "[4/8] Setup Web Root..."
mkdir -p /var/www/html
echo "<?php echo 'Halo dari Galadriel'; ?>" > /var/www/html/index.php
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "[5/8] Buat Basic Auth..."
htpasswd -bc /etc/nginx/.htpasswd noldor silvan

echo "[6/8] Konfigurasi Nginx..."
cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 8004;
    server_name galadriel.k38.com;

    root /var/www/html;
    index index.php index.html index.htm;

    # Basic Auth
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    # Blokir akses via IP langsung
    if ($host ~* "^\d+\.\d+\.\d+\.\d+$") {
        return 403;
    }

    access_log /var/log/nginx/galadriel.access.log;
    error_log /var/log/nginx/galadriel.error.log;
}
EOF

echo "[7/8] Tes dan Restart Service..."
nginx -t && service nginx restart && service php8.4-fpm restart

echo "[8/8] Setup selesai!"
echo "Uji akses pakai: curl -u noldor:silvan http://galadriel.k38.com:8004"

# celeborn

#!/bin/bash
# ===========================================
# Konfigurasi PHP Worker 3 - Oropher
# Soal No 12-14 Praktikum Komdat Jarkom
# ===========================================

echo "[1/8] Update repository..."
apt update -y

echo "[2/8] Install Nginx, PHP, dan tools..."
apt install nginx php8.4-fpm php8.4-cli php8.4-common php8.4-mysql apache2-utils -y

echo "[3/8] Jalankan service PHP-FPM..."
service php8.4-fpm start

echo "[4/8] Setup web root dan file index..."
mkdir -p /var/www/html
echo "<?php echo 'Halo dari Oropher'; ?>" > /var/www/html/index.php
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "[5/8] Buat Basic Auth..."
htpasswd -bc /etc/nginx/.htpasswd noldor silvan

echo "[6/8] Konfigurasi Nginx..."
cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 8006;
    server_name oropher.k38.com;

    root /var/www/html;
    index index.php index.html index.htm;

    # Basic Auth
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    if ($host ~* "^\d+\.\d+\.\d+\.\d+$") {
        return 403;
    }

    access_log /var/log/nginx/oropher.access.log;
    error_log /var/log/nginx/oropher.error.log;
}
EOF

echo "[7/8] Tes & restart service..."
nginx -t && service nginx restart && service php8.4-fpm restart

echo "[8/8] Setup selesai!"
echo "Tes dengan: curl -u noldor:silvan http://oropher.k38.com:8006"

# oropher 
#!/bin/bash
# ===========================================
# Konfigurasi PHP Worker 3 - Oropher
# Soal No 14 Praktikum Komdat Jarkom
# Tanpa systemctl (nevarre compatible)
# ===========================================

set -e  # Berhenti kalau ada error fatal

echo "[1/8] Update Repository..."
if ! apt update -y; then
    echo "❌ Gagal update repository! Periksa koneksi atau proses apt lain."
    ps aux | grep apt
    exit 1
fi

echo "[2/8] Install Nginx, PHP, dan utilitas..."
if ! apt install nginx php8.4-fpm php8.4-cli php8.4-common php8.4-mysql apache2-utils -y; then
    echo "❌ Instalasi gagal. Pastikan tidak ada apt yang terkunci."
    exit 1
fi

echo "[3/8] Jalankan PHP-FPM..."
service php8.4-fpm start || true
service php8.4-fpm restart || true
service php8.4-fpm status || echo "⚠️  PHP-FPM tidak aktif, periksa manual dengan 'service php8.4-fpm status'"

echo "[4/8] Setup Web Root..."
mkdir -p /var/www/html
echo "<?php echo 'Halo dari Oropher'; ?>" > /var/www/html/index.php
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "[5/8] Buat Basic Auth..."
htpasswd -bc /etc/nginx/.htpasswd noldor silvan || {
    echo "❌ Gagal membuat file .htpasswd"
    exit 1
}

echo "[6/8] Konfigurasi Nginx..."
cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 8006;
    server_name oropher.k38.com;

    root /var/www/html;
    index index.php index.html index.htm;

    # Basic Auth
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    # Blokir akses via IP langsung
    if ($host ~* "^\d+\.\d+\.\d+\.\d+$") {
        return 403;
    }

    access_log /var/log/nginx/oropher.access.log;
    error_log /var/log/nginx/oropher.error.log;
}
EOF

echo "[7/8] Tes dan Restart Service..."
if nginx -t; then
    service nginx restart
    service php8.4-fpm restart
else
    echo "❌ Konfigurasi Nginx salah! Cek dengan 'nginx -t'"
    exit 1
fi

echo "[8/8] Setup selesai!"
echo "✅ Server Oropher aktif di http://oropher.k38.com:8006"
echo "Uji akses dengan:"
echo "   curl -u noldor:silvan http://oropher.k38.com:8006"
echo "Atau tes tanpa login:"
echo "   curl http://oropher.k38.com:8006"

hasilnya setup di mirial lgsng curl 
