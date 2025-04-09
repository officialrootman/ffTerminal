#!/bin/bash

# Gelişmiş Honeypot Sistemi
# Amaç: Saldırgan aktivitelerini izlemek, analiz etmek ve sınıflandırmak.
# Yasal uyarı: Bu script yalnızca eğitim ve etik hacking amaçlıdır. İzinsiz kullanım yasa dışıdır.

# Log dosyası
LOG_FILE="elite_honeypot_logs.txt"
TMP_REQUEST="/tmp/honeypot_request.txt"
echo "Honeypot başlatıldı. Log dosyası: $LOG_FILE"

# Sahte servisleri başlat
start_honeypot() {
  echo "$(date) - Honeypot sistemi başlatılıyor..." >> $LOG_FILE
  while true; do
    # Gelen bağlantıları dinle ve logla
    { 
      echo -e "HTTP/1.1 200 OK\n\nSahte Veri: Honeypot çalışıyor"
      echo "$(date) - Sahte HTTP isteği yanıtlandı!" >> $LOG_FILE
    } | nc -l -k -p 8080 > $TMP_REQUEST &

    # Saldırganın IP adresini tespit et ve logla
    SENDER_IP=$(netstat -an | grep ":8080" | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1)
    if [ ! -z "$SENDER_IP" ]; then
      echo "$(date) - Bağlantı kuruldu! IP: $SENDER_IP" >> $LOG_FILE
    fi

    # Gelen isteği analiz et
    analyze_request
    sleep 1
  done
}

# İstek analiz fonksiyonu
analyze_request() {
  if [ -f "$TMP_REQUEST" ]; then
    REQUEST_CONTENT=$(cat $TMP_REQUEST)

    # SQL Injection tespiti
    if echo "$REQUEST_CONTENT" | grep -iq "select\|union\|drop\|insert\|update"; then
      echo "$(date) - SQL Injection saldırısı tespit edildi! IP: $SENDER_IP" >> $LOG_FILE
    fi

    # XSS (Cross-Site Scripting) saldırısı tespiti
    if echo "$REQUEST_CONTENT" | grep -iq "<script>"; then
      echo "$(date) - XSS saldırısı tespit edildi! IP: $SENDER_IP" >> $LOG_FILE
    fi

    # Brute Force tespiti
    if echo "$REQUEST_CONTENT" | grep -iq "login\|password"; then
      echo "$(date) - Brute Force denemesi tespit edildi! IP: $SENDER_IP" >> $LOG_FILE
    fi

    # Admin Panel Arama
    if echo "$REQUEST_CONTENT" | grep -iq "admin"; then
      echo "$(date) - Admin paneli araması tespit edildi! IP: $SENDER_IP" >> $LOG_FILE
    fi

    # Diğer aktiviteler
    echo "$(date) - Gelen istek: $REQUEST_CONTENT" >> $LOG_FILE
    rm -f $TMP_REQUEST
  fi
}

# Ekstra servisler ekle (örnek: sahte SSH sunucusu)
start_fake_ssh() {
  echo "$(date) - Sahte SSH servisi başlatılıyor..." >> $LOG_FILE
  while true; do
    { 
      echo "SSH-2.0-OpenSSH_7.4"
      echo "$(date) - Sahte SSH bağlantısı yanıtlandı!" >> $LOG_FILE
    } | nc -l -k -p 2222
  done
}

# Ana işlev
main() {
  # Sahte servisleri paralel olarak başlat
  start_honeypot &
  start_fake_ssh &
  wait
}

# Çıkış sinyali yakala ve temizle
trap "echo 'Honeypot durduruluyor...'; exit" SIGINT SIGTERM

# Honeypot'u başlat
main
