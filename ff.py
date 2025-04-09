#!/usr/bin/env python3

import socket
import threading
import random
import logging
import time
from datetime import datetime

class AdvancedHoneypot:
    def __init__(self):
        self.services = {
            22: "SSH",
            21: "FTP",
            80: "HTTP",
            25: "SMTP",
        }
        self.fake_data = self.generate_fake_data()
        self.log_file = "honeypot.log"
        self.setup_logging()

    def setup_logging(self):
        logging.basicConfig(
            filename=self.log_file,
            format="%(asctime)s - %(levelname)s - %(message)s",
            level=logging.INFO,
        )
        logging.info("Honeypot initialized.")

    def generate_fake_data(self):
        return {
            "users": [
                {"username": f"user{random.randint(1000,9999)}", "password": f"pass{random.randint(1000,9999)}"}
                for _ in range(5)
            ],
            "databases": [f"db_{random.randint(1,100)}" for _ in range(3)],
            "api_keys": [f"api_key_{random.randint(100000,999999)}" for _ in range(10)],
        }

    def start_service(self, port, protocol):
        try:
            server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            server.bind(("0.0.0.0", port))
            server.listen(5)
            logging.info(f"{protocol} honeypot started on port {port}")

            while True:
                client_socket, addr = server.accept()
                threading.Thread(
                    target=self.handle_connection, args=(client_socket, addr, protocol)
                ).start()
        except Exception as e:
            logging.error(f"Error starting {protocol} honeypot: {e}")

    def handle_connection(self, client_socket, addr, protocol):
        ip = addr[0]
        time_stamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        logging.info(f"Connection from {ip} on {protocol} at {time_stamp}")

        # Send fake data to attacker
        if protocol == "SSH":
            self.fake_ssh(client_socket)
        elif protocol == "FTP":
            self.fake_ftp(client_socket)
        elif protocol == "HTTP":
            self.fake_http(client_socket)
        elif protocol == "SMTP":
            self.fake_smtp(client_socket)

        client_socket.close()

    def fake_ssh(self, client_socket):
        banner = "SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.5\r\n"
        client_socket.send(banner.encode())
        time.sleep(1)
        client_socket.send(b"Password: ")
        time.sleep(1)
        client_socket.send(b"Access denied.\r\n")

    def fake_ftp(self, client_socket):
        client_socket.send(b"220 Welcome to the FTP server\r\n")
        client_socket.send(b"331 Please enter your username.\r\n")
        time.sleep(1)
        client_socket.send(b"530 Login incorrect.\r\n")

    def fake_http(self, client_socket):
        response = "HTTP/1.1 200 OK\r\n"
        response += "Content-Type: text/html\r\n\r\n"
        response += "<html><body><h1>Welcome to the Fake HTTP Server</h1></body></html>"
        client_socket.send(response.encode())

    def fake_smtp(self, client_socket):
        client_socket.send(b"220 smtp.fake.server ESMTP Postfix\r\n")
        client_socket.send(b"250 OK\r\n")
        client_socket.send(b"550 No such user here.\r\n")

    def start(self):
        threads = []
        for port, protocol in self.services.items():
            thread = threading.Thread(target=self.start_service, args=(port, protocol))
            thread.daemon = True
            threads.append(thread)
            thread.start()

        logging.info("All honeypots are running.")
        print("Honeypot is running. Logs are being saved in honeypot.log.")
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            logging.info("Honeypot shutting down.")
            print("\nHoneypot shutting down.")

if __name__ == "__main__":
    honeypot = AdvancedHoneypot()
    honeypot.start()
