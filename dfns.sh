#!/bin/sh

# Black Hat Trap Honeypot Sistemi
# Amaç: Siyah şapkalı hackerları yanıltmak, izlerini takip etmek ve rahatsız etmek.
# Yasal Uyarı: Bu script yalnızca etik kullanım ve eğitim amaçlıdır.

# === Ayarlar ===
HTTP_PORT=8080
SSH_PORT=2222
FTP_PORT=2121
TMP_HTTP_REQUEST="/tmp/http_request.txt"
TMP_SSH_REQUEST="/tmp/ssh_request.txt"
TMP_FTP_REQUEST="/tmp/ftp_request.txt"

# Zaman Damgası
timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

# Saldırganı Yavaşlatma
delay_response() {
  local SECONDS=$1
  echo "$(timestamp) - Saldırganı oyalamak için $SECONDS saniye bekleniyor..."
  sleep $SECONDS
}

# HTTP Honeypot
start_http_honeypot() {
  echo "$(timestamp) - HTTP honeypot başlatılıyor (Port: $HTTP_PORT)..."

  while true; do
    # Gelen HTTP bağlantılarını dinle
    {
      delay_response 5
      echo -e "HTTP/1.1 200 OK\n\nSahte Veri: Honeypot çalışıyor. İncelemeye devam edin..."
    } | nc -l -p $HTTP_PORT > $TMP_HTTP_REQUEST

    # Gelen isteği analiz et
    SENDER_IP=$(netstat -an | grep ":$HTTP_PORT" | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1)
    if [ ! -z "$SENDER_IP" ]; then
      echo "$(timestamp) - HTTP bağlantısı tespit edildi. IP: $SENDER_IP"
      echo "$(timestamp) - Gelen HTTP isteği: $(cat $TMP_HTTP_REQUEST)"
    fi

    # Geçici dosyayı temizle
    rm -f "$TMP_HTTP_REQUEST"
  done
}

# SSH Honeypot
start_ssh_honeypot() {
  echo "$(timestamp) - SSH honeypot başlatılıyor (Port: $SSH_PORT)..."

  while true; do
    {
      delay_response 10
      echo "SSH-2.0-OpenSSH_8.1"
    } | nc -l -p $SSH_PORT > $TMP_SSH_REQUEST

    # Gelen isteği analiz et
    SENDER_IP=$(netstat -an | grep ":$SSH_PORT" | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1)
    if [ ! -z "$SENDER_IP" ]; then
      echo "$(timestamp) - SSH bağlantısı tespit edildi. IP: $SENDER_IP"
      echo "$(timestamp) - Saldırgan, SSH brute force saldırısını deniyor olabilir!"
    fi

    # Geçici dosyayı temizle
    rm -f "$TMP_SSH_REQUEST"
  done
}

# FTP Honeypot
start_ftp_honeypot() {
  echo "$(timestamp) - FTP honeypot başlatılıyor (Port: $FTP_PORT)..."

  while true; do
    {
      delay_response 8
      echo "220 (vsFTPd 3.0.3)"
    } | nc -l -p $FTP_PORT > $TMP_FTP_REQUEST

    # Gelen isteği analiz et
    SENDER_IP=$(netstat -an | grep ":$FTP_PORT" | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1)
    if [ ! -z "$SENDER_IP" ]; then
      echo "$(timestamp) - FTP bağlantısı tespit edildi. IP: $SENDER_IP"
      echo "$(timestamp) - Saldırgan, FTP sunucusuna bağlanmaya çalışıyor. Yanıltıcı bir cevap verildi."
    fi

    # Geçici dosyayı temizle
    rm -f "$TMP_FTP_REQUEST"
  done
}

# Saldırganı Çıldırtan Yanıtlar
fake_responses() {
  echo "$(timestamp) - Saldırganı rahatsız edecek yanıtlar gönderiliyor..."
  local FAKE_DATA="{
    'username': 'root',
    'password': 'password123',
    'ssh_key': 'ssh-rsa AAAAB3Nza... honeypot'
  }"

  delay_response 3
  echo "Sahte veri oluşturuldu: $FAKE_DATA"
}

# Ana İşlev
main() {
  echo "$(timestamp) - Honeypot sistemi başlatılıyor..."

  # Paralel Servis Başlatma
  start_http_honeypot &
  start_ssh_honeypot &
  start_ftp_honeypot &
  wait
}

# Çıkış ve Temizlik
cleanup() {
  echo "$(timestamp) - Honeypot sistemi durduruluyor..."
  rm -f "$TMP_HTTP_REQUEST" "$TMP_SSH_REQUEST" "$TMP_FTP_REQUEST"
  exit 0
}

# Çıkış Sinyallerini Yakala
trap cleanup INT TERM

# Honeypot'u Başlat
main
