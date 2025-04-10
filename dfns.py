from flask import Flask, request, abort, jsonify
import redis
import time
import logging

# Redis bağlantısı: Rate Limiting ve IP izleme için
redis_client = redis.StrictRedis(host='localhost', port=6379, db=0)

# Flask uygulaması
app = Flask(__name__)

# Loglama ayarları
logging.basicConfig(filename="security_logs.log", level=logging.INFO)

# Rate Limiting ayarları
MAX_REQUESTS = 100
TIME_WINDOW = 60  # saniye

# Güvenilir IP listesi (Beyaz Liste)
WHITELIST_IPS = {"127.0.0.1"}

# Şüpheli IP listesi (Kara Liste)
BLACKLIST_IPS = set()

# CAPTCHA Doğrulama (Simülasyon)
def captcha_verification():
    return True  # Burada gerçek bir CAPTCHA entegrasyonu yapılabilir

# Trafik Analizi için örnek makine öğrenimi modeli (Simülasyon)
def analyze_traffic(ip, user_agent):
    # Saldırı tespiti için basit bir örnek analiz
    if "scanner" in user_agent.lower() or ip in BLACKLIST_IPS:
        return True
    return False

# Rate Limiting ve IP kontrolü
@app.before_request
def limit_requests():
    ip = request.remote_addr
    user_agent = request.headers.get("User-Agent", "Unknown")

    # Beyaz listedeki IP'leri kontrol et
    if ip in WHITELIST_IPS:
        return

    # Kara listedeki IP'leri kontrol et
    if ip in BLACKLIST_IPS or analyze_traffic(ip, user_agent):
        logging.warning(f"Kara listede tespit edildi: {ip}")
        abort(403, "Erişiminiz engellendi.")

    # Rate Limiting
    requests = redis_client.get(ip) or 0
    if int(requests) > MAX_REQUESTS:
        logging.warning(f"DDoS saldırısı tespit edildi: {ip}")
        if not captcha_verification():
            abort(429, "Çok fazla istek gönderildi. Lütfen daha sonra tekrar deneyin.")
    else:
        redis_client.incr(ip)
        redis_client.expire(ip, TIME_WINDOW)

# Ana rota
@app.route("/")
def home():
    return jsonify({"message": "Site güvenli!", "status": "OK"})

# Gerçek zamanlı izleme
@app.route("/monitor")
def monitor_traffic():
    active_ips = [key.decode() for key in redis_client.keys()]
    return jsonify({"active_connections": len(active_ips), "ips": active_ips})

# IP Kara Listeye Ekleme
@app.route("/blacklist/add", methods=["POST"])
def add_to_blacklist():
    ip = request.json.get("ip")
    if ip:
        BLACKLIST_IPS.add(ip)
        logging.info(f"IP kara listeye eklendi: {ip}")
        return jsonify({"message": f"{ip} kara listeye eklendi."}), 201
    return jsonify({"error": "IP adresi belirtilmedi."}), 400

# IP Beyaz Listeye Ekleme
@app.route("/whitelist/add", methods=["POST"])
def add_to_whitelist():
    ip = request.json.get("ip")
    if ip:
        WHITELIST_IPS.add(ip)
        logging.info(f"IP beyaz listeye eklendi: {ip}")
        return jsonify({"message": f"{ip} beyaz listeye eklendi."}), 201
    return jsonify({"error": "IP adresi belirtilmedi."}), 400

# Loglama
@app.errorhandler(403)
def access_denied(e):
    return jsonify({"error": str(e)}), 403

@app.errorhandler(429)
def too_many_requests(e):
    return jsonify({"error": str(e)}), 429

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
