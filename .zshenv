export LANG=ja_JP.UTF-8
export PAGER="/usr/bin/less"
export GREP_OPTIONS="--color=auto"
export HOSTNAME="centos.dev"
export TMP="$HOME/tmp"

umask 022

HISTFILE=$HOME/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

alias vi="vim"
alias sudo="sudo "

export PATH=$NODE_PATH:$PATH
export PATH="/usr/local/bin":$PATH
