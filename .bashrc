#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

complete -cf sudo

export LC_ALL=en_US.UTF-8

alias matlab='bash ~/scripts/matlab.sh'
