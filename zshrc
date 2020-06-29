### Oh-My-Zsh configuration
### {

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}
export HOME=/home
function new-experiment {
    if [[ $# -lt 1 ]]; then
        echo 'Need experiment name'
        return
    fi

    cd ~/experiments
    git clone git@github.com:voicery/tts.git $1
    cd $1
}

function new-audiobook-experiment {
    if [[ $# -lt 1 ]]; then
        echo 'Need experiment name'
        return
    fi

    cd ~/experiments
    git clone git@github.com:voicery/audiobook-studio.git $1
    cd $1
}

function rm-old-checkpoints {
    if [[ $# -lt 1 ]]; then
        echo 'Need model dir'
        return
    fi

    while [[ $# -gt 0 ]]; do
        MODEL=$1
        shift

        LAST_CHECKPOINT=$(grep '^model_checkpoint_path:' $MODEL/checkpoint | cut -f2 '-d"')
        echo "Keeping ${LAST_CHECKPOINT}. Deleting others."
        for CHECKPOINT in $MODEL/c*kp*t-*.index; do
            CHECKPOINT_NAME=$(basename ${CHECKPOINT/.index/})
            if [[ $CHECKPOINT_NAME != $LAST_CHECKPOINT ]]; then
                echo Deleting $CHECKPOINT_NAME...
                rm $CHECKPOINT ${CHECKPOINT/.index/.data}-0000*-of-0000*
            fi
        done
    done
}

function tb {
    if [[ $# -lt 2 ]]; then
        echo 'Need PORT and EXPERIMENT_NAME'
        return
    fi

    PORT="$1"
    EXPERIMENT_NAME="$2"
    tensorboard "--port=600${PORT}" "--logdir=/home/experiments/${EXPERIMENT_NAME}/runs"
}

# Path to oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export TERM=xterm-256color

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

# Share history between terminals.
setopt appendhistory
unsetopt sharehistory
unsetopt incappendhistory

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
    ./bin
    .
    $HOME/android/tools
    $HOME/android/tools/bin
    $HOME/bin/valgrind/bin
    $HOME/bin/montreal-forced-aligner/bin
    $HOME/bin

    # Mac.
    ${BREWPREFIX}/opt/coreutils/libexec/gnubin
    $HOME/.local/bin/
    $HOME/dev/*/bin
    $HOME/.stack/programs/x86_64-osx/*/bin
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

    /usr/local/nvidia/bin
    /usr/local/cuda/bin
    /home/code/tts/bin
    /home/cuda/bin
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

# Easier to reach than arrow keys.
bindkey '^[j' down-line-or-history
bindkey '^[k' up-line-or-history  

# Use Ctrl-space to accept the current prediction suggestion.
bindkey '^ ' autosuggest-execute

# Enable autojump.  The Oh-My-Zsh plugin doesn't work right now.
[ -f /Users/silver/dev/homebrew/etc/profile.d/autojump.sh ] && . /Users/silver/dev/homebrew/etc/profile.d/autojump.sh

# If there is a CUDA install, use it.
export CUDA_HOME=/home/cuda
if [[ -d $CUDA_HOME ]]; then
    export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/mkl/compilers_and_libraries/linux/mkl/lib/intel64_lin

### }
#
export GOOGLE_APPLICATION_CREDENTIALS="/home/bin/google-cloud-asr-account-key.json"

# Jake's custom aliases
if [[ $(hostname) = "jake" ]]; then
    odict() {
        if [[ $# -eq 0 ]]; then
            cat ~/data/odict.ru.sorted.txt
        else
            word="$1"; shift
            if [[ "$word" = "-a" ]]; then
                word="$1"; shift
            elif [[ "$word" = "-p" ]]; then
                word="^$1"; shift
            else
                word="^$word "
            fi
            cat ~/data/odict.ru.sorted.txt | grep $word $@
        fi
    }

    alias lc="wc -l"
fi

function jb {
    list | cut -f1 '-d ' | grep "^$1"
}

export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libhwloc.so
alias  awksum="awk '{a += "'$1'";} END { print a }'"
