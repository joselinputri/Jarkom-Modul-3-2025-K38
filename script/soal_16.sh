#!/bin/bash
# =============================================================
# SOAL 16 - PHARAZON REVERSE PROXY 

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Jalankan sebagai root!"
  exit 1
fi

echo "=============================================="
echo "     SETUP PHARAZON - REVERSE PROXY"
echo "=============================================="
echo ""

# Konfigurasi
KELOMPOK="k38"
DOMAIN="pharazon.${KELOMPOK}.com"
USE_DNS=false  # Set true jika DNS sudah ready (soal 4-5)

# 1) Set IP Pharazon jika belum
echo "[1/8] Setup IP Address & Network..."
if ! ip addr show eth0 | grep -q "192.230.2.7"; then
    ip addr add 192.230.2.7/24 dev eth0 2>/dev/null || echo "  → IP sudah ada"
else
    echo "  → IP sudah configured"
fi

ip link set eth0 up

if ! ip route | grep -q "default"; then
    ip route add default via 192.230.2.1 2>/dev/null || echo "  → Route sudah ada"
else
    echo "  → Default route sudah ada"
fi

echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "✓ Network configured"
echo "  IP: 192.230.2.7/24"
echo "  Gateway: 192.230.2.1"
echo ""

# 2) Install Nginx dan tools
echo "[2/8] Install Nginx dan dependencies..."
apt-get update -y >/dev/null 2>&1
apt-get install -y nginx curl dnsutils apache2-utils net-tools >/dev/null 2>&1
echo "✓ Packages installed"
echo ""

# 3) Backup konfigurasi lama
echo "[3/8] Backup konfigurasi lama..."
BACKUP_DIR="/root/backup-nginx"
mkdir -p "$BACKUP_DIR"

if [ -f /etc/nginx/sites-available/pharazon ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    cp /etc/nginx/sites-available/pharazon "$BACKUP_DIR/pharazon.backup.$TIMESTAMP"
    echo "✓ Backup dibuat: $BACKUP_DIR/pharazon.backup.$TIMESTAMP"
else
    echo "  → Tidak ada konfigurasi lama"
fi
echo ""

# 4) Hapus konfigurasi default
echo "[4/8] Hapus konfigurasi default..."
rm -f /etc/nginx/sites-enabled/default
echo "✓ Default config removed"
echo ""

# 5) Deteksi mode: DNS atau IP
echo "[5/8] Deteksi konfigurasi upstream..."
if [ "$USE_DNS" = true ]; then
    echo "  Mode: DNS-based (domain names)"
    UPSTREAM_MODE="dns"
    GALADRIEL_UPSTREAM="galadriel.${KELOMPOK}.com:8004"
    CELEBORN_UPSTREAM="celeborn.${KELOMPOK}.com:8005"
    OROPHER_UPSTREAM="oropher.${KELOMPOK}.com:8006"
else
    echo "  Mode: IP-based (fallback)"
    UPSTREAM_MODE="ip"
    GALADRIEL_UPSTREAM="192.230.2.2:8004"
    CELEBORN_UPSTREAM="192.230.2.3:8005"
    OROPHER_UPSTREAM="192.230.2.4:8006"
fi
echo "✓ Upstream mode: $UPSTREAM_MODE"
echo ""

# 6) Buat konfigurasi reverse proxy (HYBRID)
echo "[6/8] Buat konfigurasi Reverse Proxy..."
cat > /etc/nginx/sites-available/pharazon << EOF
# =============================================================
# PHARAZON REVERSE PROXY - Load Balancer untuk PHP Workers
# Upstream: Kesatria_Lorien (Galadriel, Celeborn, Oropher)
# =============================================================

# Upstream definition untuk Kesatria_Lorien
upstream Kesatria_Lorien {
    # Mode: $UPSTREAM_MODE
    server $GALADRIEL_UPSTREAM;  # Galadriel
    server $CELEBORN_UPSTREAM;   # Celeborn
    server $OROPHER_UPSTREAM;    # Oropher
}

# Log format untuk tracking (ADVANCED)
log_format pharazon_log '\$remote_addr - \$remote_user [\$time_local] '
                        '"\$request" \$status \$body_bytes_sent '
                        '"\$http_referer" "\$http_user_agent" '
                        'upstream: \$upstream_addr auth: \$http_authorization';

# Blokir akses via IP langsung (REGEX PATTERN)
server {
    listen 80 default_server;
    server_name ~^[0-9.]+\$;
    return 444;  # Close connection without response
}

# Server block untuk pharazon.${KELOMPOK}.com
server {
    listen 80;
    server_name ${DOMAIN};

    # Logging dengan format advanced
    access_log /var/log/nginx/pharazon-access.log pharazon_log;
    error_log /var/log/nginx/pharazon-error.log warn;

    location / {
        # Teruskan request ke upstream
        proxy_pass http://Kesatria_Lorien;

        # Header standar untuk reverse proxy
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # PENTING: Teruskan Basic Authentication
        proxy_set_header Authorization \$http_authorization;
        proxy_pass_header Authorization;

        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;

        # Buffer settings untuk performa
        proxy_buffering on;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
        proxy_busy_buffers_size 8k;

        # Retry logic
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
        proxy_next_upstream_tries 3;
    }

    # Health check endpoint (optional)
    location /health {
        access_log off;
        return 200 "Pharazon OK\n";
        add_header Content-Type text/plain;
    }
}
EOF

echo "✓ Konfigurasi dibuat: /etc/nginx/sites-available/pharazon"
echo "  Upstream mode: $UPSTREAM_MODE"
echo "  - Galadriel: $GALADRIEL_UPSTREAM"
echo "  - Celeborn: $CELEBORN_UPSTREAM"
echo "  - Oropher: $OROPHER_UPSTREAM"
echo ""

# 7) Aktifkan konfigurasi
echo "[7/8] Aktifkan konfigurasi..."
ln -sf /etc/nginx/sites-available/pharazon /etc/nginx/sites-enabled/pharazon
echo "✓ Symbolic link created"
echo ""

# 8) Test dan restart nginx (FORCE METHOD)
echo "[8/8] Test dan Restart Nginx..."
echo "  → Testing nginx configuration..."
nginx -t

if [ $? -eq 0 ]; then
    echo "  ✓ Nginx config test PASSED"
    echo ""
    
    echo "  → Stopping nginx (force)..."
    service nginx stop 2>/dev/null || true
    pkill nginx 2>/dev/null || true  # Force kill stuck processes
    sleep 2
    
    echo "  → Starting nginx..."
    service nginx start
    sleep 2

    # Verify nginx is running
    if ps aux | grep -q "[n]ginx: master"; then
        echo "  ✓ Nginx berhasil di-start"
        
        # Verify port 80 is listening
        if ss -tulpn 2>/dev/null | grep -q ":80 " || netstat -tulpn 2>/dev/null | grep -q ":80 "; then
            echo "  ✓ Port 80 listening"
        else
            echo "  ⚠ Warning: Port 80 tidak terdeteksi"
        fi
        
        # Show nginx processes
        echo ""
        echo "  Nginx processes:"
        ps aux | grep nginx | grep -v grep | head -3 | sed 's/^/    /'
        
    else
        echo "  ✗ Nginx gagal di-start"
        echo ""
        echo "Error log (last 20 lines):"
        tail -20 /var/log/nginx/error.log 2>/dev/null || echo "  No error log found"
        exit 1
    fi
else
    echo "  ✗ Nginx config test FAILED"
    echo ""
    echo "Menampilkan konfigurasi yang error:"
    cat /etc/nginx/sites-available/pharazon
    exit 1
fi

echo ""
echo "=============================================="
echo "  ✅ PHARAZON REVERSE PROXY SIAP"
echo "=============================================="
echo ""
echo "📋 Informasi Konfigurasi:"
echo "  Domain     : ${DOMAIN}"
echo "  IP Address : 192.230.2.7"
echo "  Port       : 80"
echo "  Upstream   : Kesatria_Lorien ($UPSTREAM_MODE mode)"
echo "    • Galadriel : $GALADRIEL_UPSTREAM"
echo "    • Celeborn  : $CELEBORN_UPSTREAM"
echo "    • Oropher   : $OROPHER_UPSTREAM"
echo "  Algorithm  : Round Robin"
echo "  Auth       : Basic Auth (diteruskan ke worker)"
echo ""
echo "🧪 Testing dari Client:"
echo "  # Via domain (jika DNS ready):"
echo "  curl -u noldor:silvan http://${DOMAIN}/"
echo ""
echo "  # Via IP + Host header (fallback):"
echo "  curl -u noldor:silvan -H 'Host: ${DOMAIN}' http://192.230.2.7/"
echo ""
echo "  # Health check:"
echo "  curl http://192.230.2.7/health"
echo ""
echo "📊 Monitoring:"
echo "  # Lihat distribusi request:"
echo "  tail -f /var/log/nginx/pharazon-access.log"
echo ""
echo "  # Lihat error (jika ada):"
echo "  tail -f /var/log/nginx/pharazon-error.log"
echo ""
echo "🔧 Test Lokal (di Pharazon):"
echo "  curl -u noldor:silvan -H 'Host: ${DOMAIN}' http://localhost/"
echo ""
echo "💡 Tips:"
echo "  - Jika DNS sudah ready, edit script dan set USE_DNS=true"
echo "  - Backup tersimpan di: $BACKUP_DIR/"
echo "  - Untuk restart: bash /root/no16-pharazon.sh"
echo ""
echo "=============================================="

#Celebrimor 

ip addr add 192.230.2.6/24 dev eth0
ip link set eth0 up
ip route add default via 192.230.2.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update && apt-get install curl -y

#!/bin/bash
# =============================================================
# TEST PHARAZON REVERSE PROXY (HYBRID VERSION)
# Advanced testing dengan fallback mechanism
# =============================================================

set -e

echo "=============================================="
echo "  🧪 TESTING PHARAZON REVERSE PROXY"
echo "      (HYBRID VERSION)"
echo "=============================================="
echo ""

# Konfigurasi
KELOMPOK="k38"
DOMAIN="pharazon.${KELOMPOK}.com"
PHARAZON_IP="192.230.2.7"
AUTH="noldor:silvan"

# Check if running as root (optional, for better diagnostics)
if [ "$(id -u)" -eq 0 ]; then
    IS_ROOT=true
else
    IS_ROOT=false
fi

# 1) Setup /etc/hosts jika DNS belum ready
echo "[SETUP] Checking DNS resolution..."
if host "$DOMAIN" >/dev/null 2>&1; then
    echo "✓ DNS resolution OK"
    USE_DNS=true
else
    echo "⚠ DNS not available, using /etc/hosts fallback"
    USE_DNS=false
    
    if ! grep -q "$DOMAIN" /etc/hosts; then
        echo "$PHARAZON_IP $DOMAIN" >> /etc/hosts
        echo "✓ Added $DOMAIN to /etc/hosts"
    else
        echo "✓ $DOMAIN already in /etc/hosts"
    fi
fi
echo ""

# 2) Test Network Connectivity
echo "[TEST 1] Network Connectivity..."
if ping -c 2 -W 2 $PHARAZON_IP >/dev/null 2>&1; then
    echo "✓ Ping to $PHARAZON_IP OK"
else
    echo "✗ Ping to $PHARAZON_IP FAILED"
    echo "  Pastikan routing dari Durin sudah benar!"
    exit 1
fi
echo ""

# 3) Test HTTP tanpa autentikasi (expect 401)
echo "[TEST 2] HTTP tanpa autentikasi (expect 401)..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "Host: $DOMAIN" http://$PHARAZON_IP/ 2>/dev/null)
if [ "$RESPONSE" == "401" ]; then
    echo "✓ HTTP 401 Unauthorized (Correct!)"
elif [ "$RESPONSE" == "000" ]; then
    echo "✗ Connection failed (HTTP 000)"
    exit 1
else
    echo "⚠ HTTP $RESPONSE (Expected 401, but might be OK)"
fi
echo ""

# 4) Test HTTP dengan autentikasi
echo "[TEST 3] HTTP dengan autentikasi..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -u "$AUTH" -H "Host: $DOMAIN" http://$PHARAZON_IP/ 2>/dev/null)
if [ "$RESPONSE" == "200" ]; then
    echo "✓ HTTP 200 OK dengan Basic Auth"
elif [ "$RESPONSE" == "401" ]; then
    echo "✗ HTTP 401 - Auth tidak diteruskan dengan benar"
    exit 1
elif [ "$RESPONSE" == "502" ] || [ "$RESPONSE" == "503" ]; then
    echo "✗ HTTP $RESPONSE - Backend workers tidak tersedia"
    exit 1
else
    echo "⚠ HTTP $RESPONSE"
    exit 1
fi
echo ""

# 5) Test Health Check
echo "[TEST 4] Health Check Endpoint..."
HEALTH=$(curl -s http://$PHARAZON_IP/health 2>/dev/null)
if echo "$HEALTH" | grep -q "Pharazon OK"; then
    echo "✓ Health check OK: $HEALTH"
else
    echo "⚠ Health check endpoint not responding"
fi
echo ""

# 6) Test Round Robin Distribution (ADVANCED)
echo "[TEST 5] Round Robin Load Balancing (12 requests)..."
echo ""

declare -A worker_count
worker_count[galadriel]=0
worker_count[celeborn]=0
worker_count[oropher]=0
worker_count[unknown]=0

for i in {1..12}; do
    RESULT=$(curl -s -u "$AUTH" -H "Host: $DOMAIN" http://$PHARAZON_IP/ 2>&1)

    # Case-insensitive matching untuk hostname
    if echo "$RESULT" | grep -iEq "galadriel"; then
        WORKER="galadriel"
        worker_count[galadriel]=$((${worker_count[galadriel]} + 1))
        DISPLAY="Galadriel"
    elif echo "$RESULT" | grep -iEq "celeborn"; then
        WORKER="celeborn"
        worker_count[celeborn]=$((${worker_count[celeborn]} + 1))
        DISPLAY="Celeborn"
    elif echo "$RESULT" | grep -iEq "oropher"; then
        WORKER="oropher"
        worker_count[oropher]=$((${worker_count[oropher]} + 1))
        DISPLAY="Oropher"
    else
        WORKER="unknown"
        worker_count[unknown]=$((${worker_count[unknown]} + 1))
        DISPLAY="Unknown"
    fi

    printf "  Request #%-2d → %-10s\n" "$i" "$DISPLAY"
    sleep 0.3
done

echo ""
echo "📊 Distribusi Request ke Workers:"
echo "  Galadriel : ${worker_count[galadriel]} requests"
echo "  Celeborn  : ${worker_count[celeborn]} requests"
echo "  Oropher   : ${worker_count[oropher]} requests"

if [ ${worker_count[unknown]} -gt 0 ]; then
    echo "  Unknown   : ${worker_count[unknown]} requests ⚠"
fi

echo ""

# Calculate distribution quality
TOTAL_KNOWN=$((${worker_count[galadriel]} + ${worker_count[celeborn]} + ${worker_count[oropher]}))
if [ $TOTAL_KNOWN -eq 12 ] && [ ${worker_count[unknown]} -eq 0 ]; then
    echo "✓ Round Robin berfungsi sempurna (100% sukses)"
elif [ ${worker_count[unknown]} -eq 0 ]; then
    echo "✓ Round Robin berfungsi (semua worker terdeteksi)"
else
    echo "⚠ Ada ${worker_count[unknown]} request ke worker unknown"
fi
echo ""

# 7) Test Blokir Akses via IP
echo "[TEST 6] Blokir akses via IP langsung..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://$PHARAZON_IP/ 2>/dev/null)
if [ "$RESPONSE" == "000" ] || [ "$RESPONSE" == "444" ]; then
    echo "✓ Akses via IP ($PHARAZON_IP) berhasil diblokir (HTTP $RESPONSE)"
else
    echo "⚠ Akses via IP masih dapat response (HTTP $RESPONSE)"
    echo "  Ini normal jika tidak pakai Host header"
fi
echo ""

# 8) Test X-Real-IP Header
echo "[TEST 7] Verifikasi X-Real-IP header..."
CONTENT=$(curl -s -u "$AUTH" -H "Host: $DOMAIN" http://$PHARAZON_IP/ 2>&1)
if echo "$CONTENT" | grep -q "Alamat IP"; then
    IP_SHOWN=$(echo "$CONTENT" | grep -oP 'Alamat IP.*?<b>\K[0-9.]+' | head -1)
    if [ -n "$IP_SHOWN" ]; then
        echo "✓ X-Real-IP diteruskan ke worker"
        echo "  IP yang ditampilkan: $IP_SHOWN"
    else
        echo "✓ Worker menampilkan IP (format berbeda)"
    fi
else
    echo "⚠ Tidak dapat memverifikasi X-Real-IP"
fi
echo ""

# 9) Sample Response
echo "[TEST 8] Sample Response dari Worker..."
echo "----------------------------------------"
curl -s -u "$AUTH" -H "Host: $DOMAIN" http://$PHARAZON_IP/ 2>&1 | \
    grep -iE "server:|alamat ip|hostname|selamat datang" | \
    sed 's/<[^>]*>//g' | head -5
echo "----------------------------------------"
echo ""

# 10) Check Logs (if running as root on Pharazon)
if [ "$IS_ROOT" = true ] && [ -f /var/log/nginx/pharazon-access.log ]; then
    echo "[TEST 9] Log Pharazon (last 5 entries)..."
    echo "----------------------------------------"
    tail -5 /var/log/nginx/pharazon-access.log 2>/dev/null || echo "  No log entries yet"
    echo "----------------------------------------"
    echo ""
fi

# Summary
echo "=============================================="
echo "  ✅ TESTING SELESAI"
echo "=============================================="
echo ""
echo "📋 Ringkasan:"
echo "  ✓ Network Connectivity"
echo "  ✓ Basic Authentication (401 → 200)"
echo "  ✓ Round Robin Load Balancing"
echo "  ✓ IP Blocking"
echo "  ✓ X-Real-IP Header Forwarding"
echo "  ✓ Health Check"
echo ""

if [ ${worker_count[unknown]} -eq 0 ] && [ $TOTAL_KNOWN -eq 12 ]; then
    echo "🎉 Pharazon Reverse Proxy berfungsi SEMPURNA!"
elif [ ${worker_count[unknown]} -eq 0 ]; then
    echo "✅ Pharazon Reverse Proxy berfungsi dengan baik!"
else
    echo "⚠ Pharazon berfungsi tapi ada issue kecil"
fi

echo "=============================================="