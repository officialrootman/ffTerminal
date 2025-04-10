from flask import Flask, request, abort
import redis

# Redis: Rate Limiting için kullanılır
redis_client = redis.StrictRedis(host='localhost', port=8080, db=0)

app = Flask(__name__)

# Maksimum istek sayısı
MAX_REQUESTS = 100
TIME_WINDOW = 60  # saniye

@app.route("/")
def home():
    ip = request.remote_addr
    requests = redis_client.get(ip)
    
    if requests and int(requests) > MAX_REQUESTS:
        abort(429, "Çok fazla istek gönderildi. Lütfen daha sonra tekrar deneyin.")
    
    redis_client.incr(ip)
    redis_client.expire(ip, TIME_WINDOW)
    return "Site güvenli!"

@app.errorhandler(429)
def too_many_requests(e):
    return "DDoS saldırısı tespit edildi. Erişiminiz engellendi.", 429

if __name__ == "__main__":
    app.run()
