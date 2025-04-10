import socket
import threading
import time
from datetime import datetime
import random
import string

# === Ayarlar ===
SSH_PORT = 8080
MAX_ATTEMPTS = 100000  # Brute Force saldırılarındaki maksimum giriş deneme sayısı

# === Fonksiyonlar ===
def timestamp():
    """Zaman damgası oluşturur."""
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def delay_response(seconds):
    """Saldırganı oyalamak için yanıtları geciktirir."""
    print(f"{timestamp()} - Saldırganı oyalamak için {seconds} saniye bekleniyor...")
    time.sleep(seconds)

def generate_random_string(length=8):
    """Rastgele bir string oluşturur."""
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

def generate_fake_credentials():
    """Rastgele sahte kullanıcı adı ve şifre oluşturur."""
    username = generate_random_string(random.randint(5, 10))
    password = generate_random_string(random.randint(8, 12))
    return {"username": username, "password": password}

def handle_ssh_connection(client_socket, client_address):
    """SSH honeypot bağlantılarını işler ve Brute Force saldırılarına sahte veriler gönderir."""
    print(f"{timestamp()} - SSH bağlantısı tespit edildi. IP: {client_address[0]}")

    attempts = 0
    while attempts < MAX_ATTEMPTS:
        # Sahte kullanıcı adı ve şifre oluştur
        fake_cred = generate_fake_credentials()
        response = f"Login attempt detected!\nUsername: {fake_cred['username']}\nPassword: {fake_cred['password']}\n"
        
        # Yanıtı geciktir ve saldırgana sahte veriyi gönder
        delay_response(3)
        client_socket.sendall(response.encode())
        
        print(f"{timestamp()} - Sahte veri gönderildi: Kullanıcı Adı: {fake_cred['username']}, Şifre: {fake_cred['password']}")
        
        attempts += 1

    # Brute Force denemesi limitine ulaşıldığında bağlantıyı kapat
    print(f"{timestamp()} - Brute Force denemesi sınırına ulaşıldı. IP: {client_address[0]}")
    client_socket.sendall("Too many attempts. Connection closed.\n".encode())
    client_socket.close()

def start_ssh_honeypot():
    """SSH honeypot başlatır."""
    print(f"{timestamp()} - SSH honeypot başlatılıyor (Port: {SSH_PORT})...")
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind(("0.0.0.0", SSH_PORT))
    server.listen(5)

    while True:
        client_socket, client_address = server.accept()
        thread = threading.Thread(target=handle_ssh_connection, args=(client_socket, client_address))
        thread.start()

def main():
    """Ana işlev, SSH honeypot'u başlatır."""
    print(f"{timestamp()} - Honeypot sistemi başlatılıyor...")
    start_ssh_honeypot()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"{timestamp()} - Honeypot sistemi durduruluyor...")
