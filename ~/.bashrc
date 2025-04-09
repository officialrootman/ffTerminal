# ISH Shell Style Configuration for officialrootman
# Created: 2025-04-09 14:50:09 UTC

# Terminal Renkleri
export TERM=xterm-256color

# ISH Shell Style Prompt
export PS1='\[\033[1;34m\]ish\[\033[0m\] \[\033[1;32m\]\W\[\033[0m\] → '

# Temel Aliaslar
alias ls='ls --color=auto'
alias ll='ls -la'
alias l='ls -l'
alias cls='clear'
alias grep='grep --color=auto'
alias home='cd ~'
alias ..='cd ..'
alias ...='cd ../..'

# Geçmiş Ayarları
HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL=ignoreboth

# Renkli Man Sayfaları
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# Özelleştirilmiş Fonksiyonlar
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Directory Stack
alias d='dirs -v'
alias 1='cd +1'
alias 2='cd +2'
alias 3='cd +3'
