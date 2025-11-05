Konfigurasi .env & Database
Langkah ini dilakuin di semua 3 worker (Elendil, Isildur, Anarion).
1. Masuk ke Direktori Benteng:
```
cd /var/www/benteng
```
2. Salin File .env & Buat Kunci:
          ```
# Salin dari file contoh
cp .env.example .env

# Generate kunci aplikasi Laravel
php artisan key:generate
```

##Buat Database

```
apt update
apt install mariadb-server
```
#Start Service MariaDB
```
/etc/init.d/mariadb start
```
# Cek Status
```
/etc/init.d/mariadb status
```
#Masuk ke MySQL
```
mysql
```
#Didalam mysql, buat database
-- 1. Buat database-nya
CREATE DATABASE db_benteng;

-- 2. Buat user-nya (pakai '%' biar bisa diakses dari Elendil dkk.)
CREATE USER 'user_benteng'@'%' IDENTIFIED BY 'jarkom_menyenangkan';

-- 3. Kasih user itu izin ke database baru
GRANT ALL PRIVILEGES ON db_benteng.* TO 'user_benteng'@'%';

-- 4. Terapkan perubahan
FLUSH PRIVILEGES;

-- 5. Keluar dari MariaDB
EXIT;
```
##konfigurasi di palantir (perizinan koneksi)
```
# Di terminal Palantir
nano /etc/mysql/mariadb.conf.d/50-server.cnf
```
Cari baris bind-address: Kamu akan lihat ini:
```
bind-address            = 0.0.0.0#ubah ini
```
(127.0.0.1 artinya "cuma dengerin localhost").
#restart
```
/etc/init.d/mariadb restart
```

3. Edit File .env: Buka editor-nya:
```
nano .env
```
Cari bagian DB_CONNECTION dan ubah biar konek ke Palantir (IP: 192.230.4.5):
DB_CONNECTION=mysql
DB_HOST=192.230.4.5
DB_PORT=3306
DB_DATABASE=db_benteng # (Ganti ini)
DB_USERNAME=user_benteng # (Ganti ini)
DB_PASSWORD=jarkom_menyenangkan    # (Ganti ini)

(Pastikan kamu udah bikin database dan user-nya di node Palantir ya, bro).
8.3. Konfigurasi Nginx (Gerbang Unik)
Ini yang krusial. Tiap Ksatria punya gerbang (port) dan domain-nya sendiri.
A. Di Elendil (Port 8001)
1. Buka file konfigurasi Nginx:
```
nano /etc/nginx/sites-available/default
```
2.  Hapus semua isinya dan ganti dengan ini (ganti K38):

```
server {
    # Gerbang unik Elendil
    listen 8001;

    # Hanya jawab domain ini
    server_name elendil.K38.com; 
    root /var/www/benteng/public;

    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        # Arahkan ke socket PHP 8.4
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }
}
```
B. Di Isildur (Port 8002)
Buka file: nano /etc/nginx/sites-available/default
Hapus semua isinya, ganti dengan config yang sama persis kayak Elendil, tapi UBAH 2 BARIS INI:
```
listen 8002; # Gerbang Isildur
    server_name isildur.K38.com;
```
C. Di Anarion (Port 8003)
Buka file: nano /etc/nginx/sites-available/default
Hapus semua isinya, ganti dengan config yang sama persis kayak Elendil, tapi UBAH 2 BARIS INI:
```
listen 8003; # Gerbang Anarion
    server_name anarion.K38.com;
```
8.4. Restart Service
Terakhir, restart Nginx dan PHP-FPM di semua 3 Ksatria (Elendil, Isildur, Anarion).
```
# (Jalankan di ketiga Ksatria)

# Restart Nginx
/etc/init.d/nginx restart

# Restart PHP-FPM
/etc/init.d/php8.4-fpm restart
```


