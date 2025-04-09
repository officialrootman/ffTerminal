#!/bin/bash

# Kurulum Bilgileri
INSTALL_DATE="2025-04-09 14:58:54"
INSTALL_USER="officialrootman"

# Renkler için ANSI kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Banner gösterimi
echo -e "${BLUE}"
cat << "EOF"
╔══════════════════════════════════════════╗
║     Advanced ISH Shell Style Terminal    ║
║         Custom Terminal Setup            ║
╚══════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Kurulum bilgilerini göster
echo -e "${YELLOW}Installation Date: ${NC}$INSTALL_DATE"
echo -e "${YELLOW}User: ${NC}$INSTALL_USER"
echo -e "${YELLOW}System: ${NC}$(uname -s)"

# Gerekli dizinleri oluştur
echo -e "\n${GREEN}Creating necessary directories...${NC}"
mkdir -p ~/.config/ish-terminal
mkdir -p ~/.local/share/ish-terminal
mkdir -p ~/.cache/ish-terminal

# Yedekleme işlemi
echo -e "\n${GREEN}Backing up existing configurations...${NC}"
if [ -f ~/.bashrc ]; then
    cp ~/.bashrc ~/.config/ish-terminal/bashrc.backup.$(date +%Y%m%d)
fi

# Ana yapılandırma dosyasını oluştur
echo -e "\n${GREEN}Creating main configuration file...${NC}"
cat > ~/.bashrc << 'EOF'
#!/bin/bash

# Advanced ISH Shell Style Terminal Configuration
# Created by officialrootman
# Last Updated: 2025-04-09 14:58:54

# ===== Temel Ayarlar =====
export TERM=xterm-256color
export EDITOR=nano
export VISUAL=$EDITOR
export LANG=en_US.UTF-8

# ===== Prompt Ayarları =====
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Özelleştirilmiş Prompt
export PS1='\[\033[1;34m\]ish\[\033[0m\] \[\033[1;32m\]\W\[\033[0m\]$(parse_git_branch) → '

# ===== Geçmiş Ayarları =====
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="ls:ll:cd:pwd:clear:history:exit"
HISTTIMEFORMAT="%F %T "

# Geçmişi her komuttan sonra kaydet
PROMPT_COMMAND="history -a; history -n"

# ===== Shell Seçenekleri =====
shopt -s autocd
shopt -s cdspell
shopt -s dirspell
shopt -s globstar
shopt -s histappend
shopt -s checkwinsize

# ===== Alias Tanımlamaları =====
# Sistem
alias reload='source ~/.bashrc'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias home='cd ~'

# Liste ve Dosya İşlemleri
alias ls='ls --color=auto'
alias ll='ls -la'
alias l='ls -l'
alias la='ls -A'
alias lt='ls --tree'
alias grep='grep --color=auto'
alias mkdir='mkdir -p'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Git Kısayolları
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Sistem Bilgisi
alias meminfo='free -h'
alias cpuinfo='lscpu'
alias diskinfo='df -h'

# ===== Özelleştirilmiş Fonksiyonlar =====
# Dizin oluştur ve içine gir
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Dosya arama
ff() {
    find . -type f -iname "*$1*"
}

# Dizin arama
fd() {
    find . -type d -iname "*$1*"
}

# Dosya içeriği arama
ftext() {
    grep -iRl "$1" .
}

# Sistem bilgisi göster
sysinfo() {
    echo "==== System Information ===="
    echo "Kernel: $(uname -r)"
    echo "CPU: $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2)"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $2}')"
    echo "Disk Usage: $(df -h / | awk '/\// {print $5}')"
    echo "=========================="
}

# Hızlı not alma
note() {
    if [ ! -d "$HOME/.notes" ]; then
        mkdir "$HOME/.notes"
    fi
    if [ ! "$1" ]; then
        echo "Usage: note <name>"
        return 1
    fi
    $EDITOR "$HOME/.notes/$1.txt"
}

# ===== Renk Ayarları =====
# Man sayfaları için renkler
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# Dosya türleri için renkler
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# ===== Tamamlama Ayarları =====
# Bash tamamlama
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# ===== Ortam Değişkenleri =====
export PATH="$HOME/.local/bin:$PATH"
export CDPATH=".:$HOME"

# ===== Hoş Geldin Mesajı =====
echo -e "\033[1;34m"
echo "Welcome to Advanced ISH Shell Terminal"
echo "User: $USER"
echo "Date: $(date)"
echo -e "\033[0m"

# ===== Sistem Kontrolü =====
# Disk kullanımı %90'ın üzerindeyse uyar
df -h | awk '$5 > "90%" {print "\033[1;31mWarning: Disk space is low on " $6 "\033[0m"}'

# RAM kullanımı %90'ın üzerindeyse uyar
free | awk '/Mem:/ {if($3/$2*100 > 90) print "\033[1;31mWarning: High memory usage\033[0m"}'
EOF

# Tamamlama dosyasını oluştur
echo -e "\n${GREEN}Creating bash completion file...${NC}"
touch ~/.config/ish-terminal/bash_completion

# Yapılandırmayı yükle
echo -e "\n${GREEN}Loading new configuration...${NC}"
source ~/.bashrc

echo -e "\n${BLUE}Installation Complete!${NC}"
echo -e "${YELLOW}Please restart your terminal or run 'source ~/.bashrc' to apply all changes.${NC}"
echo -e "${GREEN}Enjoy your new ISH Shell style terminal!${NC}"
