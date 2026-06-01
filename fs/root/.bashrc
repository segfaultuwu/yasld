# ~/.bashrc - YASLD

# Do nothing in non-interactive shells.
case "$-" in
	*i*) ;;
	*) return ;;
esac

# Basic env
export PATH="/bin:/sbin:/usr/bin:/usr/sbin"
export HOME="/root"
export USER="root"
export LOGNAME="root"
export SHELL="/usr/bin/bash"
export TERM="${TERM:-linux}"
export EDITOR="${EDITOR:-vi}"
export PAGER="${PAGER:-cat}"

# Colors
reset="\[\033[0m\]"
bold="\[\033[1m\]"
dim="\[\033[2m\]"
red="\[\033[31m\]"
green="\[\033[32m\]"
yellow="\[\033[33m\]"
blue="\[\033[34m\]"
magenta="\[\033[35m\]"
cyan="\[\033[36m\]"
white="\[\033[37m\]"
gray="\[\033[90m\]"

# Prompt
if [ "$(id -u 2>/dev/null)" = "0" ]; then
	prompt_symbol="#"
	prompt_color="$red"
else
	prompt_symbol="$"
	prompt_color="$green"
fi

short_pwd() {
	local p="$PWD"

	case "$p" in
		"$HOME") p="~" ;;
		"$HOME"/*) p="~/${p#$HOME/}" ;;
	esac

	printf "%s" "$p"
}

__yasld_prompt() {
	local last="$?"
	local status=""

	if [ "$last" != "0" ]; then
		status=" ${red}✗ ${last}${reset}"
	fi

	PS1="${gray}[${reset}${cyan}\u${reset}${gray}@${reset}${magenta}\h${reset} ${yellow}\$(short_pwd)${reset}${gray}]${reset}${status}\n${prompt_color}${prompt_symbol}${reset} "
}

PROMPT_COMMAND="__yasld_prompt"

# History
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend 2>/dev/null

# Bash behavior
shopt -s checkwinsize 2>/dev/null
shopt -s autocd 2>/dev/null
shopt -s cdspell 2>/dev/null
set -o vi 2>/dev/null

# Aliases
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
alias l='ls'
alias cls='clear'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias dmesg='dmesg -l'
alias ports='cat /proc/net/tcp'
alias routes='cat /proc/net/route'
alias mem='cat /proc/meminfo'
alias cpu='cat /proc/cpuinfo'
alias path='echo "$PATH" | tr ":" "\n"'

# YASLD helpers
alias fetch='fetch'
alias netlog='cat /run/init.log'
alias sshd='/usr/sbin/dropbear -R -E -s -p 22'
alias sshd-fg='/usr/sbin/dropbear -R -E -F -s -p 22'
alias myip='cat /proc/net/route; cat /etc/resolv.conf'
alias dhcpup='dhcp auto'
alias curltest='curl -4 -v --connect-timeout 5 --max-time 10 http://example.com'

# Functions
mkcd() {
	mkdir -p "$1" && cd "$1"
}

extract() {
	if [ -z "$1" ]; then
		echo "usage: extract <archive>"
		return 1
	fi

	case "$1" in
		*.tar.gz|*.tgz) tar xzf "$1" ;;
		*.tar.xz|*.txz) tar xJf "$1" ;;
		*.tar.bz2|*.tbz2) tar xjf "$1" ;;
		*.tar) tar xf "$1" ;;
		*.gz) gzip -d "$1" ;;
		*.zip) unzip "$1" ;;
		*) echo "extract: unknown archive type: $1"; return 1 ;;
	esac
}

yasld-help() {
	cat <<'EOF'
YASLD quick commands:

  fetch             show system info
  dhcpup            run DHCP on first network interface
  curltest          test HTTP with curl
  sshd              start dropbear in background, key-only auth
  sshd-fg           start dropbear in foreground
  netlog            show /run/init.log
  routes            show kernel routing table
  myip              show routes and DNS
  ll                list files
  mkcd <dir>        mkdir -p and cd into it

SSH from host:
  ssh -p 2222 root@localhost
EOF
}

# Startup banner
if [ -z "$YASLD_BASHRC_QUIET" ]; then
	echo -e "\033[36mYASLD\033[0m userspace ready. Type \033[33myasld-help\033[0m."
fi
