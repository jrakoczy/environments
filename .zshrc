unalias -m '*'

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

###############################################################################
#                                  Plugins                                    #
###############################################################################

. ~/.local/share/git-prompt.sh

###############################################################################
#                                 Completion                                  #
###############################################################################

autoload -U compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*:hosts' hosts ''
setopt completealiases

###############################################################################
#                                  History                                    #
###############################################################################

# Save to and read from .zsh_history on every command invocation.
setopt inc_append_history

# Save a timestamp and execution time.
setopt extended_history

setopt hist_ignore_dups
setopt hist_ignore_space

# Substitute a history expansion literal instead of executing a command
# immediately.
setopt hist_verify

export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=$HISTSIZE

###############################################################################
#                                  Prompt                                     #
###############################################################################

precmd() {

  local last_exitcode="$?"

  if [ "$EUID" -ne 0 ] ; then
    local L='%{%F{cyan}%B%}'
    local M='%{%b%F{cyan}%}'
    local D='%{%F{blue}%B%}'
  else
    local L='%{%F{magenta}%B%}'
    local M='%{%b%F{magenta}%}'
    local D='%{%F{red}%B%}'
  fi

  local error='%{%f%K{red}%}'
  local reset='%{%f%k%b%}'

  PS1=''

  PS1+="$D%\["
  [ "$last_exitcode" -ne 0 ] && PS1+="$error"
  PS1+="$last_exitcode]"

  PS1+=" $L%n$D [at] $L%M$D [in] $L%~"

  local git="$(__git_ps1 '%s')"
  if [ -n "$git" ] ; then
    PS1+="$D [on] $L$git"
  fi

  PS1+="$D [+] $reset"

  PS2="$M%_$D> $reset"

  RPROMPT="[%D %T]"

  print ''
}

###############################################################################
#                                  Dirstack                                   #
###############################################################################

DIRSTACKFILE="$HOME/.cache/zsh/dirs"
DIRSTACKSIZE=20

# Persist dirstack across sessions.
install -D /dev/null "$DIRSTACKFILE"
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
  dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
  [[ -d $dirstack[1] ]] && cd $dirstack[1]
fi

chpwd() {
  print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}

setopt autopushd pushdsilent

# pushd without args does `pushd ~`.
setopt pushdtohome

## Remove duplicate entries.
setopt pushdignoredups

## This reverts the +/- operators.
setopt pushdminus

###############################################################################
#                                  Aliases                                    #
###############################################################################

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias -- -='cd -'
alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

# Grep

# is x grep argument available?
grep-flag-available() {
    echo | grep $1 "" >/dev/null 2>&1
}

GREP_OPTIONS=""

# color grep results
if grep-flag-available --color=auto; then
    GREP_OPTIONS+=" --color=auto"
fi

# ignore VCS folders (if the necessary grep flags are available)
VCS_FOLDERS="{.bzr,CVS,.git,.hg,.svn}"

if grep-flag-available --exclude-dir=.cvs; then
    GREP_OPTIONS+=" --exclude-dir=$VCS_FOLDERS"
elif grep-flag-available --exclude=.cvs; then
    GREP_OPTIONS+=" --exclude=$VCS_FOLDERS"
fi

# export grep settings
alias grep="grep $GREP_OPTIONS"

# clean up
unset GREP_OPTIONS
unset VCS_FOLDERS
unfunction grep-flag-available

###############################################################################
#                            Other Env Variables                              #
###############################################################################

export VISUAL=vim
export EDITOR=vim

