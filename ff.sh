#!/bin/bash

# =================================================================
# Ultimate ISH Shell Terminal Installation Script
# Version: 2.0.0
# Created by: officialrootman
# Date: 2025-04-09 15:04:14 UTC
# License: MIT
# =================================================================

# Renk Tanımlamaları
declare -A colors=(
    ["RED"]='\033[0;31m'
    ["GREEN"]='\033[0;32m'
    ["BLUE"]='\033[0;34m'
    ["YELLOW"]='\033[1;33m'
    ["PURPLE"]='\033[0;35m'
    ["CYAN"]='\033[0;36m'
    ["WHITE"]='\033[1;37m'
    ["NC"]='\033[0m'
)

# Kurulum Bilgileri
INSTALL_DATE="2025-04-09 15:04:14"
INSTALL_USER="officialrootman"
VERSION="2.0.0"
BACKUP_DIR="$HOME/.config/ish-terminal/backups/$(date +%Y%m%d_%H%M%S)"
CONFIG_DIR="$HOME/.config/ish-terminal"
PLUGINS_DIR="$HOME/.local/share/ish-terminal/plugins"
CACHE_DIR="$HOME/.cache/ish-terminal"
LOG_FILE="$CONFIG_DIR/install.log"

# Banner gösterimi
show_banner() {
    echo -e "${colors[BLUE]}"
    cat << "EOF"
╔════════════════════════════════════════════════════╗
║             ULTIMATE ISH SHELL TERMINAL            ║
║                Version 2.0.0 - 2025               ║
║        Professional Development Environment        ║
╚════════════════════════════════════════════════════╝
EOF
    echo -e "${colors[NC]}"
}

# Logging fonksiyonu
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Hata yakalama
set -e
trap 'echo -e "${colors[RED]}Error occurred on line $LINENO${colors[NC]}" | tee -a "$LOG_FILE"' ERR

# Gerekli dizinleri oluştur
create_directories() {
    local dirs=(
        "$BACKUP_DIR"
        "$CONFIG_DIR"
        "$PLUGINS_DIR"
        "$CACHE_DIR"
        "$HOME/.local/bin"
        "$HOME/.notes"
        "$HOME/.scripts"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        log "Created directory: $dir"
    done
}

# Ana yapılandırma dosyasını oluştur
create_main_config() {
    cat > ~/.bashrc << 'EOF'
#!/bin/bash

# =================================================================
# Ultimate ISH Shell Terminal Configuration
# Version: 2.0.0
# Last Updated: 2025-04-09 15:04:14
# =================================================================

# ===== Temel Ayarlar =====
export TERM=xterm-256color
export EDITOR=nano
export VISUAL=$EDITOR
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TMPDIR="/tmp/$USER"
mkdir -p $TMPDIR

# ===== Gelişmiş Prompt =====
source ~/.config/ish-terminal/prompt.sh

# ===== Performans Optimizasyonları =====
# Önbellek boyutunu artır
ulimit -n 10000
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:ll:cd:pwd:clear:history:exit"
export HISTTIMEFORMAT="%F %T "

# Geçmişi her komuttan sonra kaydet ve senkronize et
PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

# ===== Gelişmiş Shell Seçenekleri =====
shopt -s autocd
shopt -s cdspell
shopt -s dirspell
shopt -s globstar
shopt -s histappend
shopt -s checkwinsize
shopt -s cmdhist
shopt -s lithist
shopt -s direxpand
shopt -s dotglob
shopt -s gnu_errfmt
shopt -s extglob

# ===== Profesyonel Alias Tanımlamaları =====
# Sistem Yönetimi
alias reload='source ~/.bashrc && echo "Configuration reloaded!"'
alias update='sudo apt update && sudo apt upgrade -y'
alias cls='clear && printf "\e[3J"'
alias ports='netstat -tulanp'
alias processes='ps aux | grep'
alias disk='ncdu'
alias services='systemctl list-units --type=service'

# Gelişmiş Dosya İşlemleri
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -la --group-directories-first'
alias l='ls -l --group-directories-first'
alias tree='tree -C'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias ln='ln -iv'
alias mkdir='mkdir -pv'
alias chmod='chmod -v'
alias chown='chown -v'

# Geliştirici Araçları
alias g='git'
alias gst='git status'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'
alias gpl='git pull'
alias gc='git commit'
alias gco='git checkout'
alias gb='git branch'
alias ga='git add'
alias gd='git diff'
alias docker-clean='docker system prune -af'
alias dc='docker-compose'

# Ağ Araçları
alias myip='curl -s ifconfig.me'
alias localip='hostname -I | awk "{print \$1}"'
alias ports='netstat -tulanp'
alias ping='ping -c 5'
alias websitetest='curl -s -w "\nLookup time:\t%{time_namelookup}\nConnect time:\t%{time_connect}\nPreXfer time:\t%{time_pretransfer}\nStartXfer time:\t%{time_starttransfer}\n\nTotal time:\t%{time_total}\n" -o /dev/null'

# ===== Gelişmiş Fonksiyonlar =====

# Proje Yönetimi
project() {
    case "$1" in
        "create")
            mkdir -p "$2"/{src,docs,tests,resources}
            touch "$2"/{README.md,.gitignore}
            cd "$2" || return
            git init
            echo "Project $2 created successfully!"
            ;;
        "list")
            find ~/Projects -maxdepth 1 -type d -print0 | xargs -0 -n1 basename
            ;;
        *)
            echo "Usage: project [create|list] [project_name]"
            ;;
    esac
}

# Gelişmiş Dosya Arama
search() {
    case "$1" in
        "file")
            find . -type f -iname "*$2*"
            ;;
        "content")
            grep -r "$2" .
            ;;
        "size")
            find . -type f -size "$2"
            ;;
        *)
            echo "Usage: search [file|content|size] [pattern]"
            ;;
    esac
}

# Sistem Monitörü
monitor() {
    case "$1" in
        "cpu")
            top -b -n 1 | head -n 20
            ;;
        "mem")
            free -h
            ;;
        "disk")
            df -h
            ;;
        "all")
            echo "=== CPU ===="
            top -b -n 1 | head -n 20
            echo "=== Memory ==="
            free -h
            echo "=== Disk ==="
            df -h
            ;;
        *)
            echo "Usage: monitor [cpu|mem|disk|all]"
            ;;
    esac
}

# Hızlı Not Sistemi
note() {
    local notes_dir="$HOME/.notes"
    case "$1" in
        "new")
            $EDITOR "$notes_dir/$(date +%Y%m%d_%H%M%S).md"
            ;;
        "list")
            ls -l "$notes_dir"
            ;;
        "search")
            grep -r "$2" "$notes_dir"
            ;;
        *)
            echo "Usage: note [new|list|search] [pattern]"
            ;;
    esac
}

# Geliştirici Araçları
dev() {
    case "$1" in
        "server")
            python3 -m http.server "${2:-8000}"
            ;;
        "json")
            python3 -m json.tool
            ;;
        "encode")
            echo "$2" | base64
            ;;
        "decode")
            echo "$2" | base64 -d
            ;;
        *)
            echo "Usage: dev [server|json|encode|decode] [args]"
            ;;
    esac
}

# Sistem Bakımı
maintain() {
    case "$1" in
        "clean")
            sudo apt autoremove -y
            sudo apt clean
            sudo journalctl --vacuum-time=7d
            ;;
        "update")
            sudo apt update
            sudo apt upgrade -y
            sudo apt autoremove -y
            ;;
        *)
            echo "Usage: maintain [clean|update]"
            ;;
    esac
}

# ===== Ortam Değişkenleri =====
export PATH="$HOME/.local/bin:$HOME/.scripts:$PATH"
export CDPATH=".:$HOME:$HOME/Projects"

# ===== Tamamlama Ayarları =====
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# ===== Güvenlik Kontrolleri =====
# SSH Agent Kontrolü
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > "$CONFIG_DIR/ssh-agent"
fi
if [[ "$SSH_AGENT_PID" == "" ]]; then
    eval "$(<"$CONFIG_DIR/ssh-agent")"
fi

# Sistem Durumu Kontrolü
check_system_status() {
    local warnings=()
    
    # Disk kullanımı kontrolü
    local disk_usage
    disk_usage=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)
    if [ "$disk_usage" -gt 90 ]; then
        warnings+=("Disk usage is at ${disk_usage}%")
    fi

    # RAM kullanımı kontrolü
    local memory_usage
    memory_usage=$(free | awk '/Mem:/ {print int($3/$2 * 100)}')
    if [ "$memory_usage" -gt 90 ]; then
        warnings+=("Memory usage is at ${memory_usage}%")
    fi

    # CPU yükü kontrolü
    local cpu_load
    cpu_load=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs)
    if (( $(echo "$cpu_load > 4" | bc -l) )); then
        warnings+=("High CPU load: ${cpu_load}")
    fi

    # Uyarıları göster
    if [ ${#warnings[@]} -gt 0 ]; then
        echo -e "\n${colors[YELLOW]}System Warnings:${colors[NC]}"
        printf '%s\n' "${warnings[@]}"
    fi
}

# ===== Başlangıç Mesajı =====
clear
echo -e "${colors[BLUE]}Welcome to Ultimate ISH Shell Terminal${colors[NC]}"
echo -e "${colors[YELLOW]}User: ${colors[NC]}$USER"
echo -e "${colors[YELLOW]}Date: ${colors[NC]}$(date)"
echo -e "${colors[YELLOW]}Uptime: ${colors[NC]}$(uptime -p)"
check_system_status

# ===== Eklenti Yükleyici =====
if [ -d "$PLUGINS_DIR" ]; then
    for plugin in "$PLUGINS_DIR"/*.sh; do
        if [ -f "$plugin" ]; then
            source "$plugin"
        fi
    done
fi
EOF
}

# Prompt yapılandırması
create_prompt_config() {
    cat > "$CONFIG_DIR/prompt.sh" << 'EOF'
#!/bin/bash

# Git durumunu al
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Git değişikliklerini kontrol et
parse_git_dirty() {
    [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working tree clean" ]] && echo "*"
}

# Sunucu yükünü kontrol et
get_load() {
    uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs
}

# Özelleştirilmiş prompt
PS1='\[\e[38;5;39m\]┌─[\[\e[38;5;82m\]\u\[\e[38;5;39m\]@\[\e[38;5;82m\]\h\[\e[38;5;39m\]]-[\[\e[38;5;82m\]\w\[\e[38;5;39m\]]\[\e[38;5;196m\]$(parse_git_branch)$(parse_git_dirty)\n\[\e[38;5;39m\]└─\[\e[38;5;82m\]λ\[\e[0m\] '
EOF
}

# Ana kurulum fonksiyonu
main() {
    show_banner
    
    echo -e "${colors[YELLOW]}Starting installation...${colors[NC]}"
    log "Starting installation for user: $INSTALL_USER"

    # Dizinleri oluştur
    echo -e "${colors[GREEN]}Creating directories...${colors[NC]}"
    create_directories

    # Mevcut yapılandırmayı yedekle
    echo -e "${colors[GREEN]}Backing up existing configuration...${colors[NC]}"
    if [ -f ~/.bashrc ]; then
        cp ~/.bashrc "$BACKUP_DIR/bashrc.backup"
        log "Backed up existing .bashrc"
    fi

    # Ana yapılandırmayı oluştur
    echo -e "${colors[GREEN]}Creating main configuration...${colors[NC]}"
    create_main_config
    log "Created main configuration"

    # Prompt yapılandırmasını oluştur
    echo -e "${colors[GREEN]}Creating prompt configuration...${colors[NC]}"
    create_prompt_config
    log "Created prompt configuration"

    # Gerekli paketleri kur
    echo -e "${colors[GREEN]}Installing required packages...${colors[NC]}"
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y git curl wget tree ncdu htop net-tools
        log "Installed required packages"
    fi

    # Yapılandırmayı yükle
    echo -e "${colors[GREEN]}Loading new configuration...${colors[NC]}"
    source ~/.bashrc
    log "Loaded new configuration"

    echo -e "\n${colors[BLUE]}Installation Complete!${colors[NC]}"
    echo -e "${colors[YELLOW]}Please restart your terminal or run 'source ~/.bashrc' to apply all changes.${colors[NC]}"
    echo -e "${colors[GREEN]}Installation log available at: $LOG_FILE${colors[NC]}"
}

# Kurulumu başlat
main
