#!/bin/sh

# İSH Honeypot Sistemi
# Amacı: Saldırgan aktivitelerini izlemek, loglamak ve minimal bağımlılıkla çalışmak
# Yasal Uyarı: Bu script yalnızca etik kullanım ve eğitim amaçlıdır.

# === Ayarlar ===
LOG_FILE="honeypot_ish_logs.txt"
HTTP_PORT=8080
SSH_PORT=2222
TMP_HTTP_REQUEST="/tmp/http_request.txt"
TMP_SSH_REQUEST="/tmp/ssh_request.txt"

# Zaman Damgası
timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

# Güvenli Loglama
log_event() {
  local MESSAGE=$1
  echo "$(timestamp) - $MESSAGE" >> "$LOG_FILE"
}

# HTTP Honeypot
start_http_honeypot() {
  log_event "HTTP honeypot başlatılıyor (Port: $HTTP_PORT)..."

  while true; do
    # Gelen HTTP bağlantılarını dinle
    { 
      echo -e "HTTP/1.1 200 OK\n\nSahte Veri: Honeypot çalışıyor"
    } | nc -l -p $HTTP_PORT > $TMP_HTTP_REQUEST

    # Gelen isteği analiz et
    SENDER_IP=$(netstat -an | grep ":$HTTP_PORT" | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1)
    if [ ! -z "$SENDER_IP" ]; then
      log_event "HTTP bağlantısı tespit edildi. IP: $SENDER_IP"
      log_event "Gelen HTTP isteği: $(cat $TMP_HTTP_REQUEST)"
    fi

    # Geçici dosyayı temizle
    rm -f "$TMP_HTTP_REQUEST"
  done
}

# SSH Honeypot
start_ssh_honeypot() {
  log_event "SSH honeypot başlatılıyor (Port: $SSH_PORT)..."

  while true; do
    # Sahte SSH bağlantılarını dinle
    { 
      echo "SSH-2.0-OpenSSH_8.0"
    } | nc -l -p $SSH_PORT > $TMP_SSH_REQUEST

    # Gelen isteği analiz et
    SENDER_IP=$(netstat -an | grep ":$SSH_PORT" | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1)
    if [ ! -z "$SENDER_IP" ]; then
      log_event "SSH bağlantısı tespit edildi. IP: $SENDER_IP"
    fi

    # Geçici dosyayı temizle
    rm -f "$TMP_SSH_REQUEST"
  done
}

# Ana İşlev
main() {
  # Log dosyası başlat
  log_event "Honeypot sistemi başlatılıyor..."

  # Paralel Servis Başlatma
  start_http_honeypot &
  start_ssh_honeypot &
  wait
}

# Çıkış ve Temizlik
cleanup() {
  log_event "Honeypot sistemi durduruluyor..."
  rm -f "$TMP_HTTP_REQUEST" "$TMP_SSH_REQUEST"
  exit 0
}

# Çıkış Sinyallerini Yakala
trap cleanup INT TERM

# Honeypot'u Başlat
main
