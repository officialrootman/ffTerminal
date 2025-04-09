#!/usr/bin/env python3

import socket
import threading
import paramiko
import sys
import random
import time
from datetime import datetime

class HoneypotDefender:
    def __init__(self, host='0.0.0.0', ssh_port=2222):
        self.host = host
        self.ssh_port = ssh_port
        self.fake_usernames = ['admin', 'root', 'user', 'system']
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    def generate_fake_data(self):
        # Generate convincing but fake system data
        fake_data = {
            'hostname': f'srv{random.randint(1000,9999)}',
            'uptime': f'{random.randint(1,999)} days',
            'load': f'{random.random():.2f} {random.random():.2f} {random.random():.2f}',
            'memory': f'{random.randint(1,32)}GB/{random.randint(32,128)}GB'
        }
        return fake_data

    def handle_connection(self, client, addr):
        print(f"Connection from: {addr[0]}:{addr[1]}")
        
        transport = paramiko.Transport(client)
        transport.add_server_key(paramiko.RSAKey.generate(2048))
        
        class CustomServerInterface(paramiko.ServerInterface):
            def check_auth_password(self, username, password):
                # Always return failure but delay response
                time.sleep(random.uniform(2, 5))
                return paramiko.AUTH_FAILED
            
            def get_allowed_auths(self, username):
                return 'password'

        server = CustomServerInterface()
        
        try:
            transport.start_server(server=server)
        except paramiko.SSHException:
            print("SSH negotiation failed.")
            return

        # Generate fake data for each connection
        fake_data = self.generate_fake_data()
        
        while True:
            time.sleep(random.uniform(0.1, 0.5))
            if not transport.is_active():
                break

    def start(self):
        try:
            self.sock.bind((self.host, self.ssh_port))
            self.sock.listen(100)
            print(f"[+] Listening for connections on {self.host}:{self.ssh_port}")
            
            while True:
                client, addr = self.sock.accept()
                thread = threading.Thread(target=self.handle_connection, args=(client, addr))
                thread.daemon = True
                thread.start()

        except Exception as e:
            print(f"[-] Listen/bind/accept failed: {str(e)}")
            sys.exit(1)

    def __del__(self):
        try:
            self.sock.close()
        except:
            pass

if __name__ == '__main__':
    defender = HoneypotDefender()
    try:
        defender.start()
    except KeyboardInterrupt:
        print("\n[-] Shutting down...")
        sys.exit(0)
