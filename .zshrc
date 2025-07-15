
# The following lines were added by compinstall

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _complete _ignored
zstyle ':completion:*' format 'complete: %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' matcher-list ''
zstyle ':completion:*' max-errors 6 numeric
zstyle ':completion:*' menu select=long
zstyle ':completion:*' prompt 'ERRORS IDK: %e'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=4096
SAVEHIST=4096
setopt beep
unsetopt autocd nomatch
bindkey -v
# End of lines configured by zsh-newuser-install

eval "$(starship init zsh)"

alias ls='ls --color'
alias ll='ls -al'
alias Freessh='$HOME/freessh/start.sh'
alias Wall='/usr/bin/ping 192.168.0.25'
alias :q='exit'

export PATH="$PATH:$HOME/.local/bin"
