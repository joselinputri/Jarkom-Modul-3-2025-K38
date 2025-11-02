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

# Install dependencies
apt update
apt install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2

# Add PHP 8.4 Repository
curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/php/apt.gpg
dpkg -i /tmp/debsuryorg-archive-keyring.deb
sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

apt update

# Install PHP 8.4 & Extensions
apt install -y php8.4 php8.4-fpm php8.4-cli php8.4-common php8.4-mysql \
    php8.4-xml php8.4-curl php8.4-mbstring php8.4-zip php8.4-gd \
    php8.4-intl php8.4-bcmath php8.4-soap php8.4-pdo

# Install Composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Verify
composer --version

# Install Nginx & Tools
apt install -y nginx git unzip lynx curl

# Clone Laravel Project

cd /var/www
rm -rf laravel

# Clone Laravel dari resource
git clone https://github.com/martuafernando/laravel-praktikum-jarkom.git laravel

cd laravel

# Install Composer Dependencies
composer install --no-dev --optimize-autoloader

# Set Permissions
chown -R www-data:www-data /var/www/laravel
chmod -R 755 /var/www/laravel
chmod -R 775 /var/www/laravel/storage
chmod -R 775 /var/www/laravel/bootstrap/cache

# Test PHP & Nginx
# Test PHP
php -v

# Test PHP-FPM
php-fpm8.4 -t


