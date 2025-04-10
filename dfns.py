import socket
import threading
import time
from datetime import datetime

# === Ayarlar ===
HTTP_PORT = 8080
SSH_PORT = 2222
FTP_PORT = 2121

def timestamp():
    """Zaman damgası oluşturur."""
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def delay_response(seconds):
    """Saldırganı oyalamak için yanıtları geciktirir."""
    print(f"{timestamp()} - Saldırganı oyalamak için {seconds} saniye bekleniyor...")
    time.sleep(seconds)

def handle_http_connection(client_socket, client_address):
    """HTTP honeypot bağlantılarını işler."""
    print(f"{timestamp()} - HTTP bağlantısı tespit edildi. IP: {client_address[0]}")
    delay_response(5)
    response = "HTTP/1.1 200 OK\n\nSahte Veri: Honeypot çalışıyor. İncelemeye devam edin..."
    client_socket.sendall(response.encode())
    client_socket.close()

def start_http_honeypot():
    """HTTP honeypot başlatır."""
    print(f"{timestamp()} - HTTP honeypot başlatılıyor (Port: {HTTP_PORT})...")
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind(("0.0.0.0", HTTP_PORT))
    server.listen(5)

    while True:
        client_socket, client_address = server.accept()
        thread = threading.Thread(target=handle_http_connection, args=(client_socket, client_address))
        thread.start()

def handle_ssh_connection(client_socket, client_address):
    """SSH honeypot bağlantılarını işler."""
    print(f"{timestamp()} - SSH bağlantısı tespit edildi. IP: {client_address[0]}")
    delay_response(10)
    response = "SSH-2.0-OpenSSH_8.1\n"
    client_socket.sendall(response.encode())
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

def handle_ftp_connection(client_socket, client_address):
    """FTP honeypot bağlantılarını işler."""
    print(f"{timestamp()} - FTP bağlantısı tespit edildi. IP: {client_address[0]}")
    delay_response(8)
    response = "220 (vsFTPd 3.0.3)\n"
    client_socket.sendall(response.encode())
    client_socket.close()

def start_ftp_honeypot():
    """FTP honeypot başlatır."""
    print(f"{timestamp()} - FTP honeypot başlatılıyor (Port: {FTP_PORT})...")
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind(("0.0.0.0", FTP_PORT))
    server.listen(5)

    while True:
        client_socket, client_address = server.accept()
        thread = threading.Thread(target=handle_ftp_connection, args=(client_socket, client_address))
        thread.start()

def main():
    """Ana işlev, tüm honeypot servislerini başlatır."""
    print(f"{timestamp()} - Honeypot sistemi başlatılıyor...")

    # Paralel hizmet başlatma
    http_thread = threading.Thread(target=start_http_honeypot)
    ssh_thread = threading.Thread(target=start_ssh_honeypot)
    ftp_thread = threading.Thread(target=start_ftp_honeypot)

    http_thread.start()
    ssh_thread.start()
    ftp_thread.start()

    http_thread.join()
    ssh_thread.join()
    ftp_thread.join()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"{timestamp()} - Honeypot sistemi durduruluyor...")
