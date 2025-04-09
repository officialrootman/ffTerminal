#!/bin/bash

# =================================================================
# PENTESTER'S ULTIMATE ISH SHELL TERMINAL
# Version: 3.0.0 (PenTest Edition)
# Author: officialrootman
# Created: 2025-04-09 15:14:21 UTC
# License: MIT with Security Extensions
# =================================================================

# ANSI Renk Kodları ve Özel Efektler
declare -A colors=(
    ["RED"]='\033[0;31m'
    ["LIGHT_RED"]='\033[1;31m'
    ["GREEN"]='\033[0;32m'
    ["LIGHT_GREEN"]='\033[1;32m'
    ["BLUE"]='\033[0;34m'
    ["LIGHT_BLUE"]='\033[1;34m'
    ["CYAN"]='\033[0;36m'
    ["LIGHT_CYAN"]='\033[1;36m'
    ["PURPLE"]='\033[0;35m'
    ["LIGHT_PURPLE"]='\033[1;35m'
    ["YELLOW"]='\033[1;33m'
    ["BLACK"]='\033[0;30m'
    ["DARK_GRAY"]='\033[1;30m'
    ["WHITE"]='\033[1;37m'
    ["BOLD"]='\033[1m'
    ["BLINK"]='\033[5m'
    ["NC"]='\033[0m'
)

# Kurulum Değişkenleri
readonly INSTALL_DATE="2025-04-09 15:14:21"
readonly INSTALL_USER="officialrootman"
readonly VERSION="3.0.0-pentest"
readonly BACKUP_DIR="$HOME/.config/pentest-terminal/backups/$(date +%Y%m%d_%H%M%S)"
readonly CONFIG_DIR="$HOME/.config/pentest-terminal"
readonly TOOLS_DIR="$HOME/.local/share/pentest-tools"
readonly SCRIPTS_DIR="$HOME/.scripts"
readonly LOG_DIR="$HOME/.logs"
readonly LOG_FILE="$LOG_DIR/install.log"

# Güvenlik Kontrolü
check_security() {
    if [ "$(id -u)" = "0" ]; then
        echo -e "${colors[RED]}[!] Bu script root olarak çalıştırılmamalıdır!${colors[NC]}"
        exit 1
    fi
}

# Matrix-style Banner
show_banner() {
    clear
    echo -e "${colors[GREEN]}"
    cat << "EOF"
▒█▀▀█ ▒█▀▀▀ ▒█▄░▒█ ▀▀█▀▀ ▒█▀▀▀ ▒█▀▀▀█ ▀▀█▀▀ ▒█▀▀▀ ▒█▀▀█ 
▒█▄▄█ ▒█▀▀▀ ▒█▒█▒█ ░▒█░░ ▒█▀▀▀ ░▀▀▀▄▄ ░▒█░░ ▒█▀▀▀ ▒█▄▄▀ 
▒█░░░ ▒█▄▄▄ ▒█░░▀█ ░▒█░░ ▒█▄▄▄ ▒█▄▄▄█ ░▒█░░ ▒█▄▄▄ ▒█░▒█

╔═══════════════════════════════════════════════╗
║        PENTESTER'S ULTIMATE ISH SHELL         ║
║        Security Through Knowledge             ║
╚═══════════════════════════════════════════════╝
EOF
    echo -e "${colors[NC]}"
}

# Ana Yapılandırma Dosyası
create_main_config() {
    cat > ~/.bashrc << 'EOF'
#!/bin/bash

# =================================================================
# PENTESTER'S ULTIMATE ISH SHELL CONFIGURATION
# =================================================================

# Temel Güvenlik Ayarları
umask 077
set -o noclobber
TMOUT=3600

# Gelişmiş Geçmiş Ayarları
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT="%F %T "
HISTFILE="$HOME/.logs/bash_history"
HISTSIZE=50000
HISTFILESIZE=100000

# Güvenlik Fonksiyonları
security_check() {
    local warnings=()
    
    # Rootkit kontrolü
    if command -v rkhunter >/dev/null 2>&1; then
        sudo rkhunter --check --skip-keypress > "$HOME/.logs/rkhunter.log"
    fi
    
    # Açık portları kontrol et
    netstat -tuln | grep LISTEN > "$HOME/.logs/open_ports.log"
    
    # SSH yapılandırmasını kontrol et
    if [ -f /etc/ssh/sshd_config ]; then
        grep -E "PermitRootLogin|PasswordAuthentication" /etc/ssh/sshd_config > "$HOME/.logs/ssh_config.log"
    fi
    
    # Sistem güncellemelerini kontrol et
    if command -v apt >/dev/null 2>&1; then
        apt list --upgradable 2>/dev/null > "$HOME/.logs/updates.log"
    fi
}

# Penetrasyon Testi Fonksiyonları
pentest() {
    case "$1" in
        "recon")
            echo "Starting reconnaissance..."
            nmap -sC -sV -oA scan_results "$2"
            ;;
        "scan")
            echo "Starting vulnerability scan..."
            nikto -h "$2" -o scan_"$2".txt
            ;;
        "monitor")
            echo "Starting network monitoring..."
            tcpdump -i any -w capture.pcap
            ;;
        *)
            echo "Usage: pentest [recon|scan|monitor] [target]"
            ;;
    esac
}

# Güvenlik Alias'ları
alias checksec='checksec --file'
alias scan='nmap -sC -sV'
alias sniff='sudo tcpdump -i any'
alias firewall='sudo iptables -L'
alias portscan='netstat -tulanp'
alias processes='ps aux --sort=-%cpu'
alias monitor='htop'
alias encrypt='gpg -c'
alias decrypt='gpg'
alias shred='shred -u -z'
alias secure_delete='srm -vz'
alias hide='steghide'

# Ağ Güvenliği Alias'ları
alias myip='curl -s https://api.ipify.org'
alias localnet='netdiscover -r "$(ip -o -f inet addr show | awk "/scope global/ {print \$4}")"'
alias listening='netstat -antp | grep LISTEN'
alias connections='netstat -antp | grep ESTABLISHED'
alias iptraf='sudo iptraf-ng'

# Sistem Güvenliği Alias'ları
alias chkrootkit='sudo chkrootkit'
alias rkhunter='sudo rkhunter --check'
alias lynis='sudo lynis audit system'
alias auditd='sudo auditctl -l'
alias logwatch='sudo logwatch --detail high'

# Gelişmiş Güvenlik Fonksiyonları
secure_system() {
    echo "Performing system security audit..."
    
    # Sistem günlüklerini kontrol et
    echo "Checking system logs..."
    sudo tail -n 1000 /var/log/auth.log > "$HOME/.logs/auth_check.log"
    sudo tail -n 1000 /var/log/syslog > "$HOME/.logs/system_check.log"
    
    # Açık portları tara
    echo "Scanning open ports..."
    netstat -tulanp > "$HOME/.logs/ports_check.log"
    
    # Dosya sistemi kontrolü
    echo "Checking file permissions..."
    find / -type f -perm -04000 -ls 2>/dev/null > "$HOME/.logs/suid_check.log"
    
    echo "Security audit complete. Check logs in ~/.logs/"
}

# Ağ Analiz Fonksiyonları
analyze_network() {
    echo "Starting network analysis..."
    
    # ARP tablosunu kontrol et
    arp -a > "$HOME/.logs/arp_check.log"
    
    # DNS çözümlemesini kontrol et
    dig +short google.com > "$HOME/.logs/dns_check.log"
    
    # Traceroute analizi
    traceroute google.com > "$HOME/.logs/route_check.log"
    
    echo "Network analysis complete. Check logs in ~/.logs/"
}

# Güvenlik Prompt'u
PS1='\[\e[0;31m\][\[\e[0m\]\[\e[0;37m\]\u\[\e[0m\]\[\e[0;31m\]@\[\e[0m\]\[\e[0;37m\]\h\[\e[0m\]\[\e[0;31m\]]\[\e[0m\]\[\e[0;37m\] \[\e[0m\]\[\e[0;31m\][\[\e[0m\]\[\e[0;37m\]\w\[\e[0m\]\[\e[0;31m\]]\[\e[0m\]\[\e[0;37m\]\n\[\e[0m\]\[\e[0;31m\]└─\[\e[0m\]\[\e[0;37m\]▶\[\e[0m\] '

# Başlangıç Güvenlik Kontrolü
echo -e "${colors[RED]}[*] Performing initial security check...${colors[NC]}"
security_check

# Güvenlik İpuçları
echo -e "${colors[YELLOW]}[!] Security Tips:${colors[NC]}"
echo "1. Always use encrypted connections"
echo "2. Monitor system logs regularly"
echo "3. Keep your system updated"
echo "4. Use strong passwords"
echo "5. Check for rootkits periodically"

# Sistem Bilgisi
echo -e "${colors[CYAN]}[*] System Information:${colors[NC]}"
echo "User: $USER"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"

# Güvenlik Durumu
echo -e "${colors[GREEN]}[*] Security Status:${colors[NC]}"
echo "Last Login: $(last -1 | head -1)"
echo "Failed Login Attempts: $(grep "Failed password" /var/log/auth.log | wc -l)"
echo "Open Ports: $(netstat -tuln | grep LISTEN | wc -l)"

EOF
}

# Güvenlik Araçları Kurulumu
install_security_tools() {
    echo -e "${colors[YELLOW]}Installing security tools...${colors[NC]}"
    
    # Temel güvenlik araçları
    sudo apt-get update
    sudo apt-get install -y \
        nmap \
        tcpdump \
        wireshark \
        nikto \
        netcat \
        hydra \
        john \
        aircrack-ng \
        metasploit-framework \
        burpsuite \
        sqlmap \
        dirb \
        wpscan \
        proxychains \
        tor \
        rkhunter \
        chkrootkit \
        lynis \
        fail2ban \
        net-tools \
        htop \
        iptraf-ng \
        nethogs \
        iftop \
        ntopng
}

# Ana Kurulum Fonksiyonu
main() {
    check_security
    show_banner
    
    echo -e "${colors[YELLOW]}Starting PenTester's Ultimate ISH Shell installation...${colors[NC]}"
    
    # Dizinleri oluştur
    mkdir -p "$BACKUP_DIR" "$CONFIG_DIR" "$TOOLS_DIR" "$SCRIPTS_DIR" "$LOG_DIR"
    
    # Mevcut yapılandırmayı yedekle
    if [ -f ~/.bashrc ]; then
        cp ~/.bashrc "$BACKUP_DIR/bashrc.backup"
    fi
    
    # Ana yapılandırmayı oluştur
    create_main_config
    
    # Güvenlik araçlarını kur
    install_security_tools
    
    # Yapılandırmayı yükle
    source ~/.bashrc
    
    echo -e "${colors[GREEN]}Installation complete!${colors[NC]}"
    echo -e "${colors[YELLOW]}Please restart your terminal or run 'source ~/.bashrc'${colors[NC]}"
}

# Kurulumu başlat
main
