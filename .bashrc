#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '
export PS1="\[$(tput bold)\]\[$(tput setaf 166)\][\[$(tput setaf 220)\]\u\[$(tput setaf 7)\]@\[$(tput setaf 105)\]\h \[$(tput setaf 111)\]\w\[$(tput setaf 166)\]]\[$(tput setaf 7)\]\\$ \[$(tput sgr0)\]"
complete -cf sudo

export LC_ALL=en_US.UTF-8

export PATH=$PATH:~/scripts:~/.local/bin

eval $(dircolors -b .dircolors)
