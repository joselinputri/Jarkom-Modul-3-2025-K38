# Setup Palantir
# Set DNS & Proxy
cat << EOF > /etc/resolv.conf
search K38.com
nameserver 192.230.3.10
nameserver 192.230.4.13
nameserver 192.168.122.1
EOF

export http_proxy="http://192.230.5.10:3128"
export https_proxy="http://192.230.5.10:3128"
echo 'Acquire::http::Proxy "http://192.230.5.10:3128/";' > /etc/apt/apt.conf.d/01proxy

# Install MariaDB
apt update
apt install mariadb-server -y

# Start MariaDB
mysqld_safe --datadir='/var/lib/mysql' &
sleep 5

# Setup Database & User
mysql -u root << 'MYSQL_SCRIPT'
-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password_palantir';
FLUSH PRIVILEGES;

-- Create database
CREATE DATABASE IF NOT EXISTS dbkelompok;

-- Create user untuk remote access
CREATE USER IF NOT EXISTS 'kelompok'@'%' IDENTIFIED BY 'password_kelompok';
GRANT ALL PRIVILEGES ON dbkelompok.* TO 'kelompok'@'%';
FLUSH PRIVILEGES;

-- Verify
SHOW DATABASES;
SELECT User, Host FROM mysql.user WHERE User='kelompok';
MYSQL_SCRIPT

# Configure Remote Access
cat << EOF > /etc/mysql/mariadb.conf.d/50-server.cnf
[mysqld]
user            = mysql
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
port            = 3306
basedir         = /usr
datadir         = /var/lib/mysql
tmpdir          = /tmp
lc-messages-dir = /usr/share/mysql

# Allow remote connections
bind-address    = 0.0.0.0

# Character set
character-set-server  = utf8mb4
collation-server      = utf8mb4_general_ci
EOF

# Configure .env di Workers (Elendil, Isildur, Anarion)
cd /var/www/laravel

cp .env.example .env

cat << 'EOF' > .env
APP_NAME=Laravel
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://elendil.K38.com:8001

LOG_CHANNEL=stack
LOG_LEVEL=debug

# Database Configuration (Palantir)
DB_CONNECTION=mysql
DB_HOST=192.230.3.25
DB_PORT=3306
DB_DATABASE=dbkelompok
DB_USERNAME=kelompok
DB_PASSWORD=password_kelompok

BROADCAST_DRIVER=log
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
EOF

# Generate key
php artisan key:generate

# Run migration & seeding (HANYA DI ELENDIL!)
php artisan migrate --force
php artisan db:seed --force

# Di Isildur (192.230.1.3):
cd /var/www/laravel

cp .env.example .env

cat << 'EOF' > .env
APP_NAME=Laravel
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://isildur.K38.com:8002

LOG_CHANNEL=stack
LOG_LEVEL=debug

# Database Configuration (Palantir)
DB_CONNECTION=mysql
DB_HOST=192.230.3.25
DB_PORT=3306
DB_DATABASE=dbkelompok
DB_USERNAME=kelompok
DB_PASSWORD=password_kelompok

BROADCAST_DRIVER=log
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
EOF

# Generate key
php artisan key:generate

# Di Anarion (192.230.1.12):
cd /var/www/laravel

cp .env.example .env

cat << 'EOF' > .env
APP_NAME=Laravel
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://anarion.K38.com:8003

LOG_CHANNEL=stack
LOG_LEVEL=debug

# Database Configuration (Palantir)
DB_CONNECTION=mysql
DB_HOST=192.230.3.25
DB_PORT=3306
DB_DATABASE=dbkelompok
DB_USERNAME=kelompok
DB_PASSWORD=password_kelompok

BROADCAST_DRIVER=log
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
EOF

# Generate key
php artisan key:generate

# Configure Nginx (Port Unique per Worker)
# Elendil (8001)
cat << 'EOF' > /etc/nginx/sites-available/laravel
server {
    listen 8001;
    
    # Hanya bisa diakses via domain, bukan IP
    server_name elendil.K38.com;
    
    root /var/www/laravel/public;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    access_log /var/log/nginx/elendil_access.log;
    error_log /var/log/nginx/elendil_error.log;
}
EOF

# Enable site
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/

# Test & Start
nginx -t
pkill nginx
pkill php-fpm
php-fpm8.4 -D
nginx

# Di Isildur (Port 8002):
cat << 'EOF' > /etc/nginx/sites-available/laravel
server {
    listen 8002;
    
    server_name isildur.K38.com;
    
    root /var/www/laravel/public;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    access_log /var/log/nginx/isildur_access.log;
    error_log /var/log/nginx/isildur_error.log;
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/

nginx -t
pkill nginx
pkill php-fpm
php-fpm8.4 -D
nginx

# Di Anarion (Port 8003):
cat << 'EOF' > /etc/nginx/sites-available/laravel
server {
    listen 8003;
    
    server_name anarion.K38.com;
    
    root /var/www/laravel/public;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    access_log /var/log/nginx/anarion_access.log;
    error_log /var/log/nginx/anarion_error.log;

EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/

nginx -t
pkill nginx
pkill php-fpm
php-fpm8.4 -D
nginx

