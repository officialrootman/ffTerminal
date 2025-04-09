#!/bin/bash

# ============================================
# Ultimate Honeypot Script
# ============================================
# Özellikler:
# - Dinamik sahte veri üretimi
# - Çoklu servis taklidi (SSH, HTTP, FTP)
# - Gelen komutları loglama ve analiz
# - E-posta bildirimleri
# - Docker ile izolasyon desteği

# --------------------------------------------
# Ayarlar
# --------------------------------------------
PORT_SSH=2222
PORT_HTTP=8080
PORT_FTP=2121
LOGFILE="honeypot.log"
ALERT_EMAIL="admin@example.com"
MAX_CONNECTIONS=100
DOCKER_IMAGE="honeypot_container:latest"

# --------------------------------------------
# Sahte Veri Üretim Fonksiyonları
# --------------------------------------------
generate_fake_password() {
    echo "$(openssl rand -base64 12)"
}

generate_fake_ip() {
    echo "$(shuf -i 1-255 -n 4 | paste -sd. -)"
}

generate_fake_fs() {
    echo -e "file1.txt\nfile2.txt\ndata.log\nconfig.yaml\nsecret.key"
}

generate_fake_users() {
    echo -e "admin\nroot\nguest\ndeveloper"
}

# --------------------------------------------
# Servis Fonksiyonları
# --------------------------------------------
fake_ssh_service() {
    echo "SSH-2.0-OpenSSH_8.4p1"
    echo "Giriş başarısız: Geçersiz şifre"
    echo "Son giriş IP: $(generate_fake_ip)"
    echo "Kullanıcı adı: admin"
    echo "Şifre: $(generate_fake_password)"
    echo "Dosyalar:"
    echo "$(generate_fake_fs)"
}

fake_http_service() {
    echo "HTTP/1.1 200 OK"
    echo "Content-Type: text/html"
    echo ""
    echo "<html><body><h1>Gizli Sisteme Hoş Geldiniz</h1><p>Bu sistem çok gizli veriler içeriyor.</p></body></html>"
}

fake_ftp_service() {
    echo "220 Welcome to the Fake FTP Server"
    echo "331 Please specify the password."
    echo "530 Login incorrect."
}

# --------------------------------------------
# Loglama ve Analiz
# --------------------------------------------
log_connection() {
    local ip="$1"
    local port="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Bağlantı algılandı: IP -> $ip, Port -> $port" >> $LOGFILE
    send_alert "$ip" "$port"
}

send_alert() {
    local ip="$1"
    local port="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Saldırı algılandı! IP: $ip, Port: $port" | mail -s "Honeypot Alert" $ALERT_EMAIL
}

# --------------------------------------------
# Docker ile İzolasyon
# --------------------------------------------
start_docker_honeypot() {
    echo "Docker container başlatılıyor: $DOCKER_IMAGE"
    docker run -d -p $PORT_SSH:$PORT_SSH -p $PORT_HTTP:$PORT_HTTP -p $PORT_FTP:$PORT_FTP $DOCKER_IMAGE
}

# --------------------------------------------
# Çoklu Port Dinleme
# --------------------------------------------
start_honeypot() {
    echo "Honeypot başlatılıyor..."
    echo "SSH Portu: $PORT_SSH | HTTP Portu: $PORT_HTTP | FTP Portu: $PORT_FTP"
    echo "Log dosyası: $LOGFILE"
    echo "Maksimum bağlantı: $MAX_CONNECTIONS"
    echo "-----------------------------------"

    # SSH Servisi
    while true; do
        nc -l -p $PORT_SSH -c fake_ssh_service &
    done &

    # HTTP Servisi
    while true; do
        nc -l -p $PORT_HTTP -c fake_http_service &
    done &

    # FTP Servisi
    while true; do
        nc -l -p $PORT_FTP -c fake_ftp_service &
    done &
}

# --------------------------------------------
# Ana Program
# --------------------------------------------
if [[ "$1" == "docker" ]]; then
    start_docker_honeypot
else
    start_honeypot
fi
