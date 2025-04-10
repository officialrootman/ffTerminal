from scapy.all import *
import time
import logging
from collections import defaultdict
import subprocess

# Logging ayarları
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SYNFloodDetector:
    def __init__(self, threshold=100, time_window=5):
        self.threshold = threshold  # Belirli bir sürede izin verilen maksimum SYN paketi sayısı
        self.time_window = time_window  # Zaman penceresi (saniye)
        self.syn_counts = defaultdict(list)  # Her IP için SYN paketlerini takip etmek için
        self.blocked_ips = set()  # Engellenen IP'leri saklamak için
    
    def add_iptables_rule(self, ip):
        """IP adresini iptables kullanarak engelle"""
        if ip not in self.blocked_ips:
            try:
                cmd = f"sudo iptables -A INPUT -s {ip} -j DROP"
                subprocess.run(cmd, shell=True, check=True)
                logger.info(f"IP adresi engellendi: {ip}")
                self.blocked_ips.add(ip)
            except subprocess.CalledProcessError as e:
                logger.error(f"IP engellenirken hata oluştu: {e}")

    def packet_callback(self, packet):
        """Her paket için çağrılan callback fonksiyonu"""
        if packet.haslayer(TCP) and packet[TCP].flags & 0x02:  # SYN bayrağını kontrol et
            ip_src = packet[IP].src
            current_time = time.time()
            
            # Eski kayıtları temizle
            self.syn_counts[ip_src] = [t for t in self.syn_counts[ip_src] 
                                     if current_time - t <= self.time_window]
            
            # Yeni SYN paketini kaydet
            self.syn_counts[ip_src].append(current_time)
            
            # Eşik değerini kontrol et
            if len(self.syn_counts[ip_src]) > self.threshold:
                logger.warning(f"Olası SYN flood saldırısı tespit edildi! Kaynak IP: {ip_src}")
                self.add_iptables_rule(ip_src)

    def start_monitoring(self, interface="eth0"):
        """Ağ trafiğini izlemeye başla"""
        logger.info(f"{interface} arayüzünde SYN flood saldırılarını izlemeye başladı...")
        try:
            sniff(iface=interface, prn=self.packet_callback, store=0, 
                  filter="tcp[tcpflags] & (tcp-syn) != 0")
        except KeyboardInterrupt:
            logger.info("İzleme durduruldu.")
        except Exception as e:
            logger.error(f"Hata oluştu: {e}")

if __name__ == "__main__":
    # Yeni bir detector oluştur (100 SYN paketi / 5 saniye eşiği ile)
    detector = SYNFloodDetector(threshold=100, time_window=5)
    # İzlemeyi başlat
    detector.start_monitoring()
