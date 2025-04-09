#!/usr/bin/env python3

import os
import sys
import time
from datetime import datetime

class KaliToolkitInstaller:
    def __init__(self):
        self.created_by = "officialrootman"
        self.creation_date = "2025-04-09 18:01:55"
        self.tools_dir = "/root/kali_toolkit"
        self.log_file = "kali_toolkit_install.log"

    def log(self, message):
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with open(self.log_file, "a") as f:
            f.write(f"[{timestamp}] {message}\n")
        print(message)

    def run_command(self, command):
        self.log(f"Executing: {command}")
        return os.system(command)

    def check_root(self):
        if os.geteuid() != 0:
            self.log("This script must be run as root!")
            sys.exit(1)

    def update_system(self):
        self.log("Updating system and installing dependencies...")
        base_packages = [
            "apk update",
            "apk upgrade",
            "apk add python3",
            "apk add py3-pip",
            "apk add git",
            "apk add build-base",
            "apk add linux-headers",
            "apk add python3-dev",
            "apk add openssl-dev",
            "apk add libffi-dev",
            "apk add ruby",
            "apk add ruby-dev",
            "apk add postgresql-dev",
            "apk add libpcap-dev",
            "apk add sqlite-dev"
        ]
        for cmd in base_packages:
            self.run_command(cmd)

    def install_security_tools(self):
        self.log("Installing security tools from package manager...")
        tools = [
            "nmap",
            "hydra",
            "netcat-openbsd",
            "openssh",
            "curl",
            "wget",
            "whois",
            "bind-tools",
            "traceroute",
            "tcpdump",
            "sqlite",
            "metasploit",
            "john",
            "hashcat",
            "aircrack-ng",
            "wireshark"
        ]
        for tool in tools:
            self.run_command(f"apk add {tool}")

    def install_python_packages(self):
        self.log("Installing Python security packages...")
        packages = [
            "requests",
            "scapy",
            "python-nmap",
            "paramiko",
            "cryptography",
            "beautifulsoup4",
            "pyOpenSSL",
            "mechanize",
            "netifaces",
            "dnspython",
            "pycrypto",
            "wordlist",
            "shodan",
            "censys"
        ]
        for package in packages:
            self.run_command(f"pip3 install {package}")

    def install_git_tools(self):
        self.log("Installing Git-based security tools...")
        if not os.path.exists(self.tools_dir):
            os.makedirs(self.tools_dir)
        
        os.chdir(self.tools_dir)
        
        git_repos = {
            "sqlmap": "https://github.com/sqlmapproject/sqlmap.git",
            "theHarvester": "https://github.com/laramies/theHarvester.git",
            "sherlock": "https://github.com/sherlock-project/sherlock.git",
            "dirsearch": "https://github.com/maurosoria/dirsearch.git",
            "wpscan": "https://github.com/wpscanteam/wpscan.git",
            "nikto": "https://github.com/sullo/nikto.git",
            "exploitdb": "https://github.com/offensive-security/exploitdb.git",
            "beef": "https://github.com/beefproject/beef.git"
        }

        for tool, repo in git_repos.items():
            if not os.path.exists(tool):
                self.run_command(f"git clone {repo} {tool}")
                if os.path.exists(f"{tool}/requirements.txt"):
                    self.run_command(f"pip3 install -r {tool}/requirements.txt")

    def create_aliases(self):
        self.log("Creating tool aliases...")
        aliases = [
            "alias sqlmap='python3 /root/kali_toolkit/sqlmap/sqlmap.py'",
            "alias harvester='python3 /root/kali_toolkit/theHarvester/theHarvester.py'",
            "alias sherlock='python3 /root/kali_toolkit/sherlock/sherlock'",
            "alias dirsearch='python3 /root/kali_toolkit/dirsearch/dirsearch.py'",
            "alias wpscan='ruby /root/kali_toolkit/wpscan/wpscan.rb'",
            "alias nikto='perl /root/kali_toolkit/nikto/program/nikto.pl'",
            "alias searchsploit='python3 /root/kali_toolkit/exploitdb/searchsploit'"
        ]
        
        with open("/root/.profile", "a") as f:
            f.write("\n# Kali Toolkit Aliases\n")
            for alias in aliases:
                f.write(f"{alias}\n")

    def create_menu(self):
        menu_script = """#!/usr/bin/env python3
import os
import sys
import time

class KaliToolkitMenu:
    def __init__(self):
        self.created_by = "officialrootman"
        self.creation_date = "2025-04-09 18:01:55"

    def clear_screen(self):
        os.system('clear')

    def show_banner(self):
        banner = f'''
╔══════════════════════════════════════════════╗
║             Kali Toolkit on iSH             ║
║        Created by: {self.created_by}        ║
║        Date: {self.creation_date}           ║
╚══════════════════════════════════════════════╝
        '''
        print(banner)

    def show_menu(self):
        self.clear_screen()
        self.show_banner()
        print("\\nAvailable Tools:\\n")
        print("1.  Network Scanning (Nmap)")
        print("2.  SQL Injection (SQLMap)")
        print("3.  Password Attacks (Hydra)")
        print("4.  Information Gathering (TheHarvester)")
        print("5.  OSINT Investigation (Sherlock)")
        print("6.  Web Directory Scanner (Dirsearch)")
        print("7.  WordPress Scanner (WPScan)")
        print("8.  Web Security Scanner (Nikto)")
        print("9.  Exploit Search (SearchSploit)")
        print("10. Network Sniffing (TCPDump)")
        print("11. DNS Enumeration")
        print("12. Whois Lookup")
        print("13. Hash Cracking (John/Hashcat)")
        print("14. Wireless Tools (Aircrack-ng)")
        print("15. System Information")
        print("0.  Exit")

    def run_nmap(self):
        print("\\n=== Nmap Scanner ===")
        target = input("Enter target IP/domain: ")
        scan_type = input("Select scan type:\\n1. Basic Scan\\n2. Service Version Scan\\n3. OS Detection\\n4. Script Scan\\nChoice: ")
        if scan_type == "1":
            os.system(f"nmap {target}")
        elif scan_type == "2":
            os.system(f"nmap -sV {target}")
        elif scan_type == "3":
            os.system(f"nmap -O {target}")
        elif scan_type == "4":
            os.system(f"nmap -sC {target}")

    def run_sqlmap(self):
        print("\\n=== SQLMap ===")
        url = input("Enter target URL: ")
        os.system(f"sqlmap -u {url} --batch --random-agent")

    def run_hydra(self):
        print("\\n=== Hydra ===")
        target = input("Enter target IP/hostname: ")
        service = input("Enter service (ssh/ftp/http-post-form/etc): ")
        username = input("Enter username (or path to username list): ")
        password_list = input("Enter path to password list: ")
        os.system(f"hydra -l {username} -P {password_list} {target} {service}")

    def main(self):
        while True:
            self.show_menu()
            choice = input("\\nSelect a tool (0-15): ")
            
            if choice == "1":
                self.run_nmap()
            elif choice == "2":
                self.run_sqlmap()
            elif choice == "3":
                self.run_hydra()
            elif choice == "4":
                target = input("Enter target domain: ")
                os.system(f"harvester -d {target} -b all")
            elif choice == "5":
                username = input("Enter username to search: ")
                os.system(f"sherlock {username}")
            elif choice == "6":
                url = input("Enter target URL: ")
                os.system(f"dirsearch -u {url}")
            elif choice == "7":
                url = input("Enter WordPress URL: ")
                os.system(f"wpscan --url {url}")
            elif choice == "8":
                url = input("Enter target URL: ")
                os.system(f"nikto -h {url}")
            elif choice == "9":
                search = input("Enter search term: ")
                os.system(f"searchsploit {search}")
            elif choice == "10":
                interface = input("Enter interface (default: eth0): ") or "eth0"
                os.system(f"tcpdump -i {interface}")
            elif choice == "11":
                domain = input("Enter domain: ")
                os.system(f"dig {domain}")
            elif choice == "12":
                target = input("Enter domain/IP: ")
                os.system(f"whois {target}")
            elif choice == "13":
                hashfile = input("Enter path to hash file: ")
                os.system(f"john {hashfile}")
            elif choice == "14":
                interface = input("Enter wireless interface: ")
                os.system(f"aircrack-ng {interface}")
            elif choice == "15":
                os.system("uname -a && cat /etc/os-release")
            elif choice == "0":
                print("\\nExiting Kali Toolkit...")
                sys.exit(0)
            else:
                print("Invalid choice!")
            
            input("\\nPress Enter to continue...")

if __name__ == "__main__":
    menu = KaliToolkitMenu()
    menu.main()
"""
        with open("/root/kali_menu.py", "w") as f:
            f.write(menu_script)
        self.run_command("chmod +x /root/kali_menu.py")

    def install(self):
        try:
            self.check_root()
            
            print("\n=== Kali Toolkit Installer for iSH Shell ===")
            print(f"Created by: {self.created_by}")
            print(f"Date: {self.creation_date}\n")

            steps = [
                ("Updating system and installing dependencies", self.update_system),
                ("Installing security tools", self.install_security_tools),
                ("Installing Python packages", self.install_python_packages),
                ("Installing Git-based tools", self.install_git_tools),
                ("Creating aliases", self.create_aliases),
                ("Creating menu interface", self.create_menu)
            ]

            for step_name, step_func in steps:
                print(f"\n[+] {step_name}...")
                step_func()

            print("\n[+] Installation completed successfully!")
            print("[+] To start the toolkit, run: python3 /root/kali_menu.py")
            print("[+] To load aliases, run: source ~/.profile")

        except Exception as e:
            self.log(f"Error during installation: {str(e)}")
            print("\n[-] Installation failed! Check kali_toolkit_install.log for details.")
            sys.exit(1)

if __name__ == "__main__":
    installer = KaliToolkitInstaller()
    installer.install()
