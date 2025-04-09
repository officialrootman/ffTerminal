import os
import sys
import socket
import subprocess
import readline
import platform
import pwd
import time
import threading
import base64
import hashlib
import requests
import signal
from colorama import Fore, Back, Style, init
from cryptography.fernet import Fernet

class EthicalTerminal:
    def __init__(self):
        init(autoreset=True)
        self.current_dir = os.getcwd()
        self.username = os.getenv('USER') or os.getenv('USERNAME')
        self.hostname = socket.gethostname()
        self.history = []
        self.running = True
        self.banner = f"""{Fore.GREEN}
╔══════════════════════════════════════════╗
║     Ethical Hacking Terminal v1.0        ║
║     Created by Security Enthusiast       ║
║     Use responsibly and legally          ║
╚══════════════════════════════════════════╝
{Style.RESET_ALL}"""
        self.custom_commands = {
            'scan': self.network_scan,
            'encrypt': self.encrypt_file,
            'decrypt': self.decrypt_file,
            'hash': self.hash_string,
            'monitor': self.network_monitor,
            'clear': self.clear_screen,
            'sysinfo': self.system_info,
            'help': self.show_help
        }
        self.setup_terminal()

    def setup_terminal(self):
        if platform.system() != "Windows":
            os.system('clear')
        else:
            os.system('cls')
        print(self.banner)
        self.encryption_key = Fernet.generate_key()
        self.cipher_suite = Fernet(self.encryption_key)

    def get_prompt(self):
        return f"{Fore.BLUE}{self.username}@{self.hostname}{Style.RESET_ALL}:{Fore.GREEN}{self.current_dir}{Style.RESET_ALL}$ "

    def network_scan(self, args):
        try:
            target = args[0] if args else '127.0.0.1'
            print(f"{Fore.YELLOW}Scanning {target}...{Style.RESET_ALL}")
            for port in range(1, 1025):
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(0.1)
                result = sock.connect_ex((target, port))
                if result == 0:
                    print(f"{Fore.GREEN}Port {port}: Open{Style.RESET_ALL}")
                sock.close()
        except Exception as e:
            print(f"{Fore.RED}Error during scan: {str(e)}{Style.RESET_ALL}")

    def encrypt_file(self, args):
        if not args:
            print(f"{Fore.RED}Please provide a file path to encrypt{Style.RESET_ALL}")
            return
        try:
            with open(args[0], 'rb') as file:
                file_data = file.read()
            encrypted_data = self.cipher_suite.encrypt(file_data)
            with open(f"{args[0]}.encrypted", 'wb') as file:
                file.write(encrypted_data)
            print(f"{Fore.GREEN}File encrypted successfully{Style.RESET_ALL}")
        except Exception as e:
            print(f"{Fore.RED}Encryption error: {str(e)}{Style.RESET_ALL}")

    def decrypt_file(self, args):
        if not args:
            print(f"{Fore.RED}Please provide a file path to decrypt{Style.RESET_ALL}")
            return
        try:
            with open(args[0], 'rb') as file:
                encrypted_data = file.read()
            decrypted_data = self.cipher_suite.decrypt(encrypted_data)
            with open(args[0].replace('.encrypted', '.decrypted'), 'wb') as file:
                file.write(decrypted_data)
            print(f"{Fore.GREEN}File decrypted successfully{Style.RESET_ALL}")
        except Exception as e:
            print(f"{Fore.RED}Decryption error: {str(e)}{Style.RESET_ALL}")

    def hash_string(self, args):
        if not args:
            print(f"{Fore.RED}Please provide a string to hash{Style.RESET_ALL}")
            return
        text = ' '.join(args)
        hashes = {
            'MD5': hashlib.md5(text.encode()).hexdigest(),
            'SHA1': hashlib.sha1(text.encode()).hexdigest(),
            'SHA256': hashlib.sha256(text.encode()).hexdigest(),
            'SHA512': hashlib.sha512(text.encode()).hexdigest()
        }
        for algorithm, hash_value in hashes.items():
            print(f"{Fore.CYAN}{algorithm}: {hash_value}{Style.RESET_ALL}")

    def network_monitor(self, args):
        print(f"{Fore.YELLOW}Starting network monitoring (Press Ctrl+C to stop)...{Style.RESET_ALL}")
        try:
            while True:
                output = subprocess.check_output(['netstat', '-an']).decode()
                print(f"\n{Fore.CYAN}Active Connections:{Style.RESET_ALL}")
                print(output)
                time.sleep(2)
        except KeyboardInterrupt:
            print(f"{Fore.YELLOW}Network monitoring stopped{Style.RESET_ALL}")
        except Exception as e:
            print(f"{Fore.RED}Error monitoring network: {str(e)}{Style.RESET_ALL}")

    def clear_screen(self, args):
        if platform.system() != "Windows":
            os.system('clear')
        else:
            os.system('cls')
        print(self.banner)

    def system_info(self, args):
        info = {
            'System': platform.system(),
            'Node Name': platform.node(),
            'Release': platform.release(),
            'Version': platform.version(),
            'Machine': platform.machine(),
            'Processor': platform.processor()
        }
        for key, value in info.items():
            print(f"{Fore.CYAN}{key}: {Fore.GREEN}{value}{Style.RESET_ALL}")

    def show_help(self, args):
        commands = {
            'scan [host]': 'Scan ports on specified host',
            'encrypt [file]': 'Encrypt a file',
            'decrypt [file]': 'Decrypt a file',
            'hash [text]': 'Generate hash values for text',
            'monitor': 'Monitor network connections',
            'clear': 'Clear the screen',
            'sysinfo': 'Display system information',
            'exit': 'Exit the terminal',
            'help': 'Show this help message'
        }
        print(f"{Fore.CYAN}Available Commands:{Style.RESET_ALL}")
        for cmd, desc in commands.items():
            print(f"{Fore.GREEN}{cmd:<20}{Fore.YELLOW}{desc}{Style.RESET_ALL}")

    def execute_command(self, command):
        if not command:
            return
        self.history.append(command)
        parts = command.split()
        cmd = parts[0].lower()
        args = parts[1:]

        if cmd == 'exit':
            self.running = False
            print(f"{Fore.YELLOW}Goodbye!{Style.RESET_ALL}")
            return

        if cmd in self.custom_commands:
            self.custom_commands[cmd](args)
        else:
            try:
                output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT)
                print(output.decode())
            except subprocess.CalledProcessError as e:
                print(f"{Fore.RED}Error executing command: {e.output.decode()}{Style.RESET_ALL}")
            except Exception as e:
                print(f"{Fore.RED}Error: {str(e)}{Style.RESET_ALL}")

    def run(self):
        while self.running:
            try:
                command = input(self.get_prompt())
                self.execute_command(command)
            except KeyboardInterrupt:
                print("\n" + f"{Fore.YELLOW}Use 'exit' to quit{Style.RESET_ALL}")
            except EOFError:
                break

if __name__ == "__main__":
    terminal = EthicalTerminal()
    terminal.run()
