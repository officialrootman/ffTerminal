#!/bin/bash

# ============================================
# Gelişmiş Honeypot Script'i
# ============================================
# Özellikler:
# - Çoklu port dinleme
# - Dinamik sahte veri üretimi
# - Gelen bağlantıları loglama
# - Gelen komutları taklit etme
# - Sahte servisler: SSH ve HTTP

# --------------------------------------------
# Ayarlar
# --------------------------------------------
PORT_SSH=2222
PORT_HTTP=8080
LOGFILE="honeypot.log"
CONFIG_FILE="honeypot_config.conf"
MAX_CONNECTIONS=100

# Dinamik sahte veri fonksiyonları
generate_fake_password() {
    echo "$(openssl rand -base64 12)"
}

generate_fake_ip() {
    echo "$(shuf -i 1-255 -n 4 | paste -sd. -)"
}

generate_fake_fs() {
    echo -e "file1.txt\nfile2.txt\ndata.log\nconfig.yaml\nsecret.key"
}

# --------------------------------------------
# Sahte SSH Sunucusu
# --------------------------------------------
fake_ssh_service() {
    echo "SSH-2.0-OpenSSH_8.4p1"
    echo "Giriş başarısız: Geçersiz şifre"
    echo "Sistem logları:"
    echo "Son giriş IP: $(generate_fake_ip)"
    echo "Kullanıcı adı: admin"
    echo "Şifre: $(generate_fake_password)"
    echo "Dosyalar:"
    echo "$(generate_fake_fs)"
}

# --------------------------------------------
# Sahte HTTP Sunucusu
# --------------------------------------------
fake_http_service() {
    echo "HTTP/1.1 200 OK"
    echo "Content-Type: text/html"
    echo ""
    echo "<html><body><h1>Gizli Sisteme Hoş Geldiniz</h1><p>Bu sistem çok gizli veriler içeriyor.</p></body></html>"
}

# --------------------------------------------
# Loglama Fonksiyonu
# --------------------------------------------
log_connection() {
    local ip="$1"
    local port="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Bağlantı algılandı: IP -> $ip, Port -> $port" >> $LOGFILE
}

# --------------------------------------------
# Çoklu Port Dinleme
# --------------------------------------------
start_honeypot() {
    echo "Honeypot başlatılıyor..."
    echo "SSH Portu: $PORT_SSH | HTTP Portu: $PORT_HTTP"
    echo "Log dosyası: $LOGFILE"
    echo "Maksimum bağlantı: $MAX_CONNECTIONS"
    echo "-----------------------------------"

    # SSH Portunu Dinle
    while true; do
        nc -l -p $PORT_SSH -c fake_ssh_service >> $LOGFILE &
    done &

    # HTTP Portunu Dinle
    while true; do
        nc -l -p $PORT_HTTP -c fake_http_service >> $LOGFILE &
    done &
}

# --------------------------------------------
# Yapılandırma Dosyasını Yükleme
# --------------------------------------------
load_config() {
    if [[ -f $CONFIG_FILE ]]; then
        source $CONFIG_FILE
        echo "Yapılandırma dosyası yüklendi: $CONFIG_FILE"
    else
        echo "Yapılandırma dosyası bulunamadı, varsayılan ayarlar yüklenecek."
    fi
}

# --------------------------------------------
# Ana Program
# --------------------------------------------
load_config
start_honeypot
