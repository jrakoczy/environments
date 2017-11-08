unalias -m '*'

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

###############################################################################
#                                  Plugins                                    #
###############################################################################

plugins_path=~/.local/share/zsh-plugins
fpath=($plugins_path $fpath)

. "$plugins_path/git-prompt"

# Directory aliases.
autoload -Uz wd

# Auto-completion.
autoload -U compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*:hosts' hosts ''
setopt completealiases

# Command history completion.
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

unset plugins_path

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

prompt_color() {
    local hash="$(md5sum <<< "$hostname" | head -c5)"
    print "$((16#$hash % 255))"
}

precmd() {
  local last_exitcode="$?"

  local hostname_color="$(prompt_color)"
  local primary="%{%F{$hostname_color}%B%}"
  local secondary="%{%F{$((($hostname_color + 10) % 255))}%B%}"
  local reset='%{%f%k%b%}'

  PS1=''

  PS1+="$secondary%\[$last_exitcode]"

  # user [at] host [in] directory
  PS1+=" $primary%n$secondary [at] $primary%M$secondary [in] $primary%~"

  # [on] branch
  local git="$(__git_ps1 '%s')"
  if [ -n "$git" ] ; then
    PS1+="$secondary [on] $primary$git"
  fi

  # Type a command in a new line.
  PS1+="
> $reset"

  PS2="$secondary> $reset"

  # Date-time.
  RPROMPT="[%D %T]"

  # Separate commands with an empty line.
  print ''
}

###############################################################################
#                                  Dirstack                                   #
###############################################################################

DIRSTACKFILE="$HOME/.cache/zsh/dirs"
DIRSTACKSIZE=20

# Persist dirstack across sessions.

if [[ ! -f $DIRSTACKFILE ]]; then
    install -D /dev/null "$DIRSTACKFILE"
fi

if [[ $#dirstack -eq 0 ]]; then
    dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
    [[ -d $dirstack[1] ]] && cd $dirstack[1]
fi

chpwd() {
  print -l "$PWD" ${(u)dirstack} >"$DIRSTACKFILE"
}

setopt autopushd pushdsilent

# pushd without args does `pushd ~`.
setopt pushdtohome

# Remove duplicate entries.
setopt pushdignoredups

# This reverts the +/- operators.
setopt pushdminus

###############################################################################
#                                  Aliases                                    #
###############################################################################

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

# Grep

# is x grep argument available?
grep-flag-available() {
    echo | grep "$1" "" >/dev/null 2>&1
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
#                                Key bindings                                 #
###############################################################################

typeset -A key

key[Home]=${terminfo[khome]}

key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# Command history completion.
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-beginning-search
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-beginning-search

###############################################################################
#                            Other Env Variables                              #
###############################################################################

export VISUAL=vim
export EDITOR=vim

###############################################################################
#                              Startup setup                                  #
###############################################################################

# Import a colorscheme for each new session, suppressing all control messages.
# The `-t` switch prevents from printing junk output on session start.
(wal -r -t &)

if [ "$TMUX" = "" ]; then
    tmux -2
fi

# Clean up all stale warping points.
wd clean! > /dev/null
