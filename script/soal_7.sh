Bagian 1: Instalasi Tools (Di 3 Ksatria)
Lakukan langkah-langkah ini di terminal Elendil, Isildur, DAN Anarion.
1.1. Instal Nginx, Composer, dan PHP
```
# 1. Update daftar paket
apt update

# 2. Instal Nginx, Composer, Git, dan PHP 8.4
# (Kita tambahkan php8.4-cli & ekstensi umum Laravel)
apt install nginx curl composer git php8.4-fpm php8.4-cli php8.4-mysql php8.4-mbstring php8.4-xml php8.4-curl php8.4-zip -y
```
1.2. Dapatkan Cetak Biru (Source Code)
```
# 1. Buat folder untuk web-nya
mkdir -p /var/www/benteng

# 2. Clone resource-nya (ganti <URL_GIT> dengan URL resource kamu)
git clone https://github.com/elshiraphine/laravel-simple-rest-api /var/www/benteng

# 3. Masuk ke folder & install dependensi Laravel
cd /var/www/benteng
composer install --no-dev
composer update
```
(Pastikan kamu lakukan ini di ketiga node Ksatria).
Bagian 2: Instalasi Lynx (Di Klien)
Sekarang pindah ke satu node Klien (misal Gilgalad atau Miriel) untuk menginstal lynx.
```
# Di terminal Gilgalad
apt update
apt install lynx -y
```
Bagian 3: Cek dengan Lynx
Ini adalah bagian testing dari soal. Kalau kamu coba sekarang:
```
# Di terminal Gilgalad
lynx elendil.K38.com
```
Hasilnya PASTI GAGAL atau akan nampilin halaman "Welcome to Nginx" (default).
Kenapa? Kita baru install Nginx, tapi kita belum mengkonfigurasi "benteng"-nya (Nginx server block) untuk menjalankan aplikasi Laravel di /var/www/benteng.


