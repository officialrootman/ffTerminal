#!/bin/bash

# Sahte HTTP sunucusunu başlat
echo "Honeypot sahte sunucusu başlatılıyor..."

# Sahte sunucu için log dosyası
LOG_FILE="logs.txt"

# Netcat ile sahte bir HTTP sunucusu oluştur
while true; do
  # Bağlantıyı dinle ve yanıt ver
  echo -e "HTTP/1.1 200 OK\n\nSahte Veri: Honeypot çalışıyor" | nc -l -p 8080 >> $LOG_FILE

  # Gelen bağlantıyı logla
  echo "$(date) - Saldırgan bağlandı!" >> $LOG_FILE
done
