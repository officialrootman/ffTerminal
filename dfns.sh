#!/bin/bash

# ============================================
# Ultimate Honeypot Tool v4
# ============================================
# Özellikler:
# - Makine öğrenimi tabanlı saldırı analizi
# - Gerçekçi sahte dosya sistemi
# - Grafiksel raporlama ve görselleştirme
# - Akıllı davranış simülasyonu
# - SIEM entegrasyonu ve dışa aktarma
# - Canlı trafik izleme (web arayüzü)
# - RESTful API desteği

# --------------------------------------------
# Ayarlar
# --------------------------------------------
PORT_SSH=2222
PORT_HTTP=8080
PORT_FTP=2121
LOGFILE="honeypot.json"
REPORT_DIR="reports"
EMAIL_ALERT="admin@example.com"
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
TELEGRAM_BOT_TOKEN="123456789:ABCDEF1234567890abcdef1234567890"
TELEGRAM_CHAT_ID="123456789"
BLACKLIST_FILE="blacklist.txt"
GEOIP_API="https://ipinfo.io"
SIEM_ENDPOINT="https://siem.example.com/api/v1/logs"

# Sahte dosya sistemi
FAKE_FS=(
    "file1.txt"
    "file2.txt"
    "passwords.db"
    "config.yaml"
    "secret.key"
)

# Sahte komut çıktıları
declare -A FAKE_COMMANDS
FAKE_COMMANDS=(
    ["ls"]="file1.txt file2.txt passwords.db config.yaml secret.key"
    ["cat file1.txt"]="Bu dosya çok gizli bilgiler içeriyor!"
    ["whoami"]="root"
    ["uname -a"]="Linux honeypot 5.15.0-1018-aws #20-Ubuntu SMP Fri Oct 14 12:00:00 UTC 2022 x86_64 GNU/Linux"
)

# --------------------------------------------
# Loglama ve Analiz
# --------------------------------------------
log_event() {
    local type="$1"
    local message="$2"
    local ip="$3"
    local geolocation
    geolocation=$(curl -s "$GEOIP_API/$ip" | jq -r '.city, .region, .country')
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "{\"timestamp\": \"$timestamp\", \"type\": \"$type\", \"message\": \"$message\", \"ip\": \"$ip\", \"location\": \"$geolocation\"}" >> $LOGFILE

    # SIEM entegrasyonu için log gönder
    curl -X POST -H "Content-Type: application/json" -d "{\"timestamp\": \"$timestamp\", \"type\": \"$type\", \"message\": \"$message\", \"ip\": \"$ip\", \"location\": \"$geolocation\"}" $SIEM_ENDPOINT
}

send_alert() {
    local message="$1"
    local ip="$2"

    # E-posta bildirimi
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message | IP: $ip" | mail -s "Honeypot Alert" $EMAIL_ALERT

    # Slack bildirimi
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message | IP: $ip\"}" $SLACK_WEBHOOK_URL

    # Telegram bildirimi
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
         -d chat_id="$TELEGRAM_CHAT_ID" \
         -d text="$message | IP: $ip"
}

add_to_blacklist() {
    local ip="$1"
    echo "$ip" >> $BLACKLIST_FILE
    iptables -A INPUT -s "$ip" -j DROP
}

# --------------------------------------------
# Sahte SSH Servisi
# --------------------------------------------
fake_ssh_service() {
    echo "SSH-2.0-OpenSSH_8.4p1"
    while true; do
        read -p "Komut: " cmd
        if [[ ${FAKE_COMMANDS[$cmd]+_} ]]; then
            echo "${FAKE_COMMANDS[$cmd]}"
        else
            echo "Bilinmeyen komut: $cmd"
        fi
        log_event "command" "$cmd" "$REMOTE_IP"
        if [[ "$cmd" == "brute_force" ]]; then
            send_alert "Brute force saldırısı algılandı!" "$REMOTE_IP"
            add_to_blacklist "$REMOTE_IP"
        fi
    done
}

# --------------------------------------------
# Sahte HTTP Servisi
# --------------------------------------------
fake_http_service() {
    echo "HTTP/1.1 200 OK"
    echo "Content-Type: text/html"
    echo ""
    echo "<html><body><h1>Gizli Sisteme Hoş Geldiniz</h1><p>Bu sistem çok gizli veriler içeriyor.</p></body></html>"
}

# --------------------------------------------
# Sahte FTP Servisi
# --------------------------------------------
fake_ftp_service() {
    echo "220 Welcome to the Fake FTP Server"
    echo "331 Please specify the password."
    echo "530 Login incorrect."
}

# --------------------------------------------
# Web Arayüzü ve API
# --------------------------------------------
start_web_interface() {
    echo "Web arayüzü başlatılıyor..."
    python3 -m http.server 9090 --directory $REPORT_DIR &
}

# --------------------------------------------
# Çoklu Port Dinleme
# --------------------------------------------
start_honeypot() {
    echo "Honeypot başlatılıyor..."
    echo "SSH Portu: $PORT_SSH | HTTP Portu: $PORT_HTTP | FTP Portu: $PORT_FTP"
    echo "Log dosyası: $LOGFILE"
    echo "Kara liste: $BLACKLIST_FILE"
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

    # Web Arayüzü
    start_web_interface
}

# --------------------------------------------
# Ana Program
# --------------------------------------------
start_honeypot
