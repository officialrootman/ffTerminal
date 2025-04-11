from flask import Flask, request, jsonify
from flask_talisman import Talisman
from flask_wtf.csrf import CSRFProtect

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your_secret_key'

# Talisman: Güvenlik başlıkları
Talisman(app)

# CSRF Koruması
csrf = CSRFProtect(app)

@app.route('/')
def home():
    return "Bu site güvenlik önlemleri ile korunuyor!"

@app.route('/data', methods=['POST'])
def data():
    # Kullanıcıdan gelen verilerin doğruluğunu kontrol et
    user_input = request.json.get('input')
    if not user_input:
        return jsonify({"error": "Invalid input"}), 400
    return jsonify({"message": "Veri başarıyla alındı!"})

if __name__ == '__main__':
    app.run(debug=False)
