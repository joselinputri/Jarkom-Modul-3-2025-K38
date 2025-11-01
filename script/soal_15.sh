#galadriel

#!/bin/bash
# ===========================================
# Konfigurasi PHP Worker 1 - Galadriel
# ===========================================

set -e

echo "[1/8] Update Repository..."
if ! apt update -y; then
    echo "Gagal update repository. Pastikan tidak ada proses apt lain."
    exit 1
fi

echo "[2/8] Install Nginx, PHP, dan utilitas..."
if ! apt install nginx php8.4-fpm php8.4-cli php8.4-common php8.4-mysql apache2-utils -y; then
    echo "Gagal instalasi paket."
    exit 1
fi

echo "[3/8] Pastikan PHP-FPM aktif..."
service php8.4-fpm start || true
service php8.4-fpm restart || true

echo "[4/8] Setup Web Root..."
mkdir -p /var/www/html
cat > /var/www/html/index.php <<'EOF'
<?php
$ip = $_SERVER['REMOTE_ADDR'];
if (!empty($_SERVER['HTTP_X_REAL_IP'])) {
    $ip = $_SERVER['HTTP_X_REAL_IP'];
}
echo "Halo dari Galadriel!<br>";
echo "Alamat IP pengunjung: " . htmlspecialchars($ip);
?>
EOF
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
        fastcgi_param HTTP_X_REAL_IP $remote_addr;
    }

    if ($host ~* "^\d+\.\d+\.\d+\.\d+$") {
        return 403;
    }

    access_log /var/log/nginx/galadriel.access.log;
    error_log /var/log/nginx/galadriel.error.log;
}
EOF

echo "[7/8] Tes dan Restart Service..."
if nginx -t; then
    service nginx restart
    service php8.4-fpm restart
else
    echo "Konfigurasi Nginx bermasalah."
    exit 1
fi

echo "[8/8] Setup selesai."
echo "Akses: curl -u noldor:silvan http://galadriel.k38.com:8004"

# celeborn

#!/bin/bash
# ===========================================
# Konfigurasi PHP Worker 2 - Celeborn
# ===========================================

set -e

echo "[1/8] Update Repository..."
if ! apt update -y; then
    echo "Gagal update repository."
    exit 1
fi

echo "[2/8] Install Nginx, PHP, dan utilitas..."
if ! apt install nginx php8.4-fpm php8.4-cli php8.4-common php8.4-mysql apache2-utils -y; then
    echo "Gagal instalasi paket."
    exit 1
fi

echo "[3/8] Pastikan PHP-FPM aktif..."
service php8.4-fpm start || true
service php8.4-fpm restart || true

echo "[4/8] Setup Web Root..."
mkdir -p /var/www/html
cat > /var/www/html/index.php <<'EOF'
<?php
$ip = $_SERVER['REMOTE_ADDR'];
if (!empty($_SERVER['HTTP_X_REAL_IP'])) {
    $ip = $_SERVER['HTTP_X_REAL_IP'];
}
echo "Halo dari Celeborn!<br>";
echo "Alamat IP pengunjung: " . htmlspecialchars($ip);
?>
EOF
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "[5/8] Buat Basic Auth..."
htpasswd -bc /etc/nginx/.htpasswd noldor silvan

echo "[6/8] Konfigurasi Nginx..."
cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 8005;
    server_name celeborn.k38.com;

    root /var/www/html;
    index index.php index.html index.htm;

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
        fastcgi_param HTTP_X_REAL_IP $remote_addr;
    }

    if ($host ~* "^\d+\.\d+\.\d+\.\d+$") {
        return 403;
    }

    access_log /var/log/nginx/celeborn.access.log;
    error_log /var/log/nginx/celeborn.error.log;
}
EOF

echo "[7/8] Tes dan Restart Service..."
if nginx -t; then
    service nginx restart
    service php8.4-fpm restart
else
    echo "Konfigurasi Nginx bermasalah."
    exit 1
fi

echo "[8/8] Setup selesai."
echo "Akses: curl -u noldor:silvan http://celeborn.k38.com:8005"

# oropher

#!/bin/bash
# ===========================================
# Konfigurasi PHP Worker 3 - Oropher
# ===========================================

set -e

echo "[1/8] Update Repository..."
if ! apt update -y; then
    echo "Gagal update repository."
    exit 1
fi

echo "[2/8] Install Nginx, PHP, dan utilitas..."
if ! apt install nginx php8.4-fpm php8.4-cli php8.4-common php8.4-mysql apache2-utils -y; then
    echo "Gagal instalasi paket."
    exit 1
fi

echo "[3/8] Pastikan PHP-FPM aktif..."
service php8.4-fpm start || true
service php8.4-fpm restart || true

echo "[4/8] Setup Web Root..."
mkdir -p /var/www/html
cat > /var/www/html/index.php <<'EOF'
<?php
$ip = $_SERVER['REMOTE_ADDR'];
if (!empty($_SERVER['HTTP_X_REAL_IP'])) {
    $ip = $_SERVER['HTTP_X_REAL_IP'];
}
echo "Halo dari Oropher!<br>";
echo "Alamat IP pengunjung: " . htmlspecialchars($ip);
?>
EOF
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
        fastcgi_param HTTP_X_REAL_IP $remote_addr;
    }

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
    echo "Konfigurasi Nginx bermasalah."
    exit 1
fi

echo "[8/8] Setup selesai."
echo "Akses: curl -u noldor:silvan http://oropher.k38.com:8006"

# miriel

​​#!/bin/bash
# ===========================================
# Konfigurasi Client - Miriel
# ===========================================

echo "[1/3] Set nameserver..."
echo "nameserver 192.168.122.1" > /etc/resolv.conf

echo "[2/3] Mapping domain ke IP worker..."
cat >> /etc/hosts <<'EOF'
192.230.2.3 galadriel.k38.com
192.230.2.4 celeborn.k38.com
192.230.2.5 oropher.k38.com
EOF

echo "[3/3] Tes koneksi ke semua worker..."
curl -u noldor:silvan http://galadriel.k38.com:8004
curl -u noldor:silvan http://celeborn.k38.com:8005
curl -u noldor:silvan http://oropher.k38.com:8006

chmod +x /root/15.sh
bash /root/15.sh


