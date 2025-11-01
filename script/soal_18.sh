# pelantir

#!/bin/bash
set -euo pipefail

MYSQL="mysql -u root -proot123"

echo "=== [PALANTIR] Setup Master MariaDB ==="

# --- Network config ---
ip addr flush dev eth0 || true
ip addr add 192.230.4.5/24 dev eth0
ip link set eth0 up
ip route replace default via 192.230.4.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "[+] Network OK"

# --- Prepare MariaDB folders ---
mkdir -p /var/run/mysqld /var/log/mysql
chown -R mysql:mysql /var/run/mysqld /var/log/mysql /var/lib/mysql

# --- Kill old MariaDB ---
pkill -9 mariadbd || true
sleep 2

# --- Start MariaDB Master ---
echo "[+] Starting MariaDB Master..."
mariadbd --user=mysql \
--datadir=/var/lib/mysql \
--socket=/var/run/mysqld/mysqld.sock \
--bind-address=0.0.0.0 \
--server-id=1 \
--log-bin=/var/log/mysql/mysql-bin.log &
sleep 5

# --- Setup database & replication user ---
$MYSQL -e "
DROP DATABASE IF EXISTS jarkom;
CREATE DATABASE jarkom;
USE jarkom;
CREATE TABLE test (id INT AUTO_INCREMENT PRIMARY KEY, nama VARCHAR(255));
DROP USER IF EXISTS 'repl'@'%';
CREATE USER 'repl'@'%' IDENTIFIED BY 'repl123';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
"

echo "=== MASTER STATUS ==="
$MYSQL -e "SHOW MASTER STATUS;"
echo "[✓] Palantir (Master) siap!"


# narvi 
#!/bin/bash
set -euo pipefail

MYSQL="mysql -u root -proot123"

echo "=== [NARVI] Setup Slave MariaDB ==="

# --- Network config ---
ip addr flush dev eth0 || true
ip addr add 192.230.4.4/24 dev eth0
ip link set eth0 up
ip route replace default via 192.230.4.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "[+] Network OK"

# --- Prepare MariaDB folders ---
mkdir -p /var/run/mysqld /var/log/mysql
chown -R mysql:mysql /var/run/mysqld /var/log/mysql /var/lib/mysql

# --- Kill old MariaDB ---
pkill -9 mariadbd || true
sleep 2

# --- Start MariaDB Slave ---
echo "[+] Starting MariaDB Slave..."
mariadbd --user=mysql \
--datadir=/var/lib/mysql \
--socket=/var/run/mysqld/mysqld.sock \
--bind-address=0.0.0.0 \
--server-id=2 &
sleep 5

# --- Configure Slave ---
$MYSQL <<EOF
STOP SLAVE;
RESET SLAVE ALL;
DROP DATABASE IF EXISTS jarkom;
CHANGE MASTER TO
MASTER_HOST='192.230.4.5',
MASTER_USER='repl',
MASTER_PASSWORD='repl123',
MASTER_LOG_FILE='mysql-bin.000011',
MASTER_LOG_POS=1413,
MASTER_PORT=3306;
START SLAVE;
EOF

# --- Cek status slave ---
echo "=== SLAVE STATUS ==="
$MYSQL -e "SHOW SLAVE STATUS\G" | grep -E "Running|Error|Master_Log"
echo "[✓] Narvi (Slave) siap dan replikasi berjalan!"

pelantir 
mysql -u root -proot123
USE jarkom;

-- Tambah tabel baru untuk uji replikasi
CREATE TABLE IF NOT EXISTS test2 (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(255)
);

-- Masukkan data baru
INSERT INTO test2 (nama) VALUES ('Frodo');
INSERT INTO test2 (nama) VALUES ('Samwise');

narvi
mysql -u root -proot123
USE jarkom;

-- Cek tabel baru
SHOW TABLES;

-- Lihat data tabel
SELECT * FROM test2;





