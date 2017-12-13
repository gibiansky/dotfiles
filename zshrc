### Oh-My-Zsh configuration
### {

# Path to oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Chosen oh-my-zsh theme.
ZSH_THEME="flazz"

# Do not check for updates. I don't want my shell checking for updates.
DISABLE_AUTO_UPDATE="true"

# Show red dots while waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Plugins to use with oh-my-zsh.
plugins=(git autojump zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

### }

### Miscellaneous options via [un]setopt ###
### {

# Load colors. What would I do without fancy colors?
autoload colors && colors

# Allow moving to directories without 'cd'
setopt autocd

# Don't beep. Ever. Seriously!
setopt no_hist_beep
unsetopt beep

# Allow fancy zsh globs!
setopt extendedglob

# Don't complain when there are no matched files.
unsetopt nomatch

# Don't let zsh interrupt me with notifications of completed background jobs.
unsetopt notify

### }

### History config ###
### {

# Make history more or less arbitrarily large.
HISTFILE=~/.histfile
HISTSIZE=10000000
SAVEHIST=10000000

# Store timestamps and time elapsed in history.
set extendedhistory

# Incrementally append to history, as soon as things are entered.
setopt incappendhistory

# Don't have duplicates in history.
setopt histignoredups

# Get rid of extraneous whitespace in history commands.
setopt hist_reduce_blanks

# Don't store 'history' and 'fc' commands into the history.
setopt histnostore

### }

### PATH and MANPATH variables ###
### {

# Convenience function to trim path to existing directories only.
# Stolen from zsh.sourceforge.net/Contrib/startup/users/debbiep/dot.zshenv.
rationalize-path () {
  # Note that this works only on arrays, not colon-delimited strings.
  # Not that this is a problem now that there is typeset -T.
  local element
  local build
  build=()
  # Evil quoting to survive an eval and to make sure that
  # this works even with variables containing IFS characters, if I'm
  # crazy enough to setopt shwordsplit.
  eval '
  foreach element in "$'"$1"'[@]"
  do
    if [[ -d "$element" ]]
    then
      build=("$build[@]" "$element")
    fi
  done
  '"$1"'=( "$build[@]" )
  '
}

BREWPREFIX="$HOME/dev/homebrew"
path=(
    .
    $HOME/bin

    # Mac.
    ${BREWPREFIX}/opt/coreutils/libexec/gnubin
    $HOME/.local/bin/
    $HOME/dev/*/bin
    $HOME/.stack/programs/x86_64-osx/*/bin
    $HOME/code/*/bin
    $HOME/.cabal/bin

    # Homebrew.
    ${BREWPREFIX}/opt/coreutils/libexec/gnubin

    # Default paths.
    /usr/local/sbin
    /usr/local/bin
    /usr/sbin
    /usr/bin
    /sbin
    /bin
    /usr/games
)
export PATH

# Add gnu coreutils man pages to default.
export MANPATH=$MANPATH:${BREWPREFIX}/findutils/share/man
export MANPATH=$MANPATH:${BREWPREFIX}/opt/coreutils/share/man
export MANPATH=$MANPATH:${BREWPREFIX}/opt/coreutils/libexec/gnuman

# Only unique entries please.
typeset -U path

# Remove entries that don't exist on the filesystem.
rationalize-path path

### }

### Custom Aliases and Tweaks
### {

if [[ `uname` == Darwin ]]; then
    # Do not show the default Mac directories.
    alias ls='gls --color --hide=Documents --hide=Movies --hide=Music --hide=Pictures --hide=Public --hide=Library --hide=Desktop --hide=Applications'
fi

# Go up directories easily.
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'

# Python startup files.
export PYTHONSTARTUP=$HOME/.pythonrc.py

# Shortcut for decompressing a tarball.
alias untar='tar -xvvf'

# Activate the virtualenv environment given.
function activate {
    source $1/bin/activate
}

# If there is anv 'env' in my home, go ahead and load it.
if [[ -d ~/env ]]; then
    activate ~/env
fi

# Turn on `nvim` as the default editor if it exists.
which nvim &>/dev/null
if [[ $? -eq 0 ]]; then
    alias vim='nvim'
    alias vi='nvim'
    export EDITOR=nvim
else
    export EDITOR=vim
fi

# Shortcut for getting disk usage of a directory.
alias duh='du -h --summarize'

# Extended history viewing.
alias history='history 0'

# Brew provisioning: run this to get a list of commands to run.
alias brew-provision='$HOME/code/dotfiles/utils/brew-packages $HOME/code/dotfiles/packages $HOME/code/dotfiles/casks'

# A shorter shortcut to editing the current command-line.
bindkey '^g' edit-command-line

# Use Ctrl-space to accept the current prediction suggestion.
bindkey '^ ' autosuggest-execute

# Enable autojump.  The Oh-My-Zsh plugin doesn't work right now.
[ -f /Users/silver/dev/homebrew/etc/profile.d/autojump.sh ] && . /Users/silver/dev/homebrew/etc/profile.d/autojump.sh

### }
