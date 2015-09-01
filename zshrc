# Be xterm, since that's more or less the standard.
export TERM=xterm
export EDITOR=nvim

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

### zsh completion ###
### {

# Display different types of matches separately, since there are no groups.
zstyle ':completion:*' group-name ''

# Color completion.
zmodload zsh/complist
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Complete directories first.
zstyle ':completion:*' list-dirs-first true

# Show a helpful prompt when there are too many completions.
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s

# Allow approximate completions with one error.
zstyle ':completion:*' max-errors 1 numeric

# Use menu completion all the time, with a custom prompt.
zstyle ':completion:*' menu select
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

# Assume that "//" is the same as "/" for completion purposes.
zstyle ':completion:*' squeeze-slashes true

# Load completion functions.
autoload -Uz compinit && compinit

# Ignore some extensions for vim completion.
zstyle ':completion:*' ignored-patterns *.hi *.o *.aux *.log *.pdf

### }

### $PATH variable ###
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

path=(
    .
    $HOME/bin

    # fasd.
    $HOME/.zsh/fasd

    # Mac.
    $HOME/dev/homebrew/opt/coreutils/libexec/gnubin
    $HOME/.local/bin/
    $HOME/dev/*/bin
    /usr/texbin
    /Applications/MATLAB_*.app/bin
    /Developer/NVIDIA/CUDA-6.5/bin
    $HOME/.stack/programs/x86_64-osx/*/bin

    $HOME/.cabal/bin

    # User-local packages. 
    $HOME/.cabal/bin
    $HOME/.local/bin

    # Homebrew.
    /usr/local/bin
    $HOME/dev/homebrew/opt/coreutils/libexec/gnubin

    # Default paths.
    /usr/local/sbin
    /usr/sbin
    /usr/bin
    /sbin
    /bin
    /usr/games
)
export PATH

# Add gnu coreutils man pages to default.
export MANPATH=/usr/local/opt/findutils/share/man:/usr/local/opt/coreutils/share/man:$MANPATH
export MANPATH=$HOME/dev/homebrew/opt/coreutils/libexec/gnuman:$MANPATH

# Only unique entries please.
typeset -U path

# Remove entries that don't exist on the filesystem.
rationalize-path path
export PATH=./.cabal-sandbox/bin:$PATH

### }

### Zsh prompt construction ###
### {

# Allow substitutions in prompts, at every prompting.
setopt prompt_subst

# Variable shortcuts for colors.
green="%{$fg[green]%}"
red="%{$fg[red]%}"
blue="%{$fg[blue]%}"
cyan="%{$fg[cyan]%}"
bold_cyan="%{$fg_bold[cyan]%}"
bold_blue="%{$fg_bold[blue]%}"
color_reset="%{$reset_color%}"

# %? is the return code of the process.
# %U/%u is start and stop underline, respectively.
# %) is a close parenthesis (required %).
return_code="(%Uret %?%u%)" 

# The syntax for conditional expressions is %n(X.true-text.false-text), where n is an integer
# (defaulting to 0 if not provided) and X is a test character. The different tests are detailed
# at www.acm.uiuc.edu/workshops/zsh/prompt/conditionals.html, but the ? test is true if the exit
# static of the previous process was equal to the integer n.
# 
# Color the prompt green normally, and red if the command fails. If it fails, print the return code.
exit_color="%0(?.$green.$red)"
exit_code_color="%0(?.$green.$red$return_code )"

# History number: %! is the current command in the history.
history_num="[%!]"

# Current time, in 24 hour format, with seconds.
cur_time="%*"

# The user@hostname part.
prompt_user="%n@%m"

# Use a different prompt character if I'm inside a git repository.
function prompt_char {
    BRANCH=`=git branch 2> /dev/null | grep '*' | sed 's/* //'`
    BRANCH_NAME=${BRANCH:0:15}...
    =git branch >/dev/null 2>/dev/null && echo "($BRANCH_NAME) ⇒" && return
    echo '$'
}

# Use a special version of the working directory.
function working_dir {
    # Get the actual directory, replacing $HOME with ~.
    REAL_PWD=$(pwd | sed s,$HOME,~,);

    # Break up directory into lines.
    DIRS=$(echo $REAL_PWD | tr '/' '\n')

    # How many directories to leave unshortened.
    UNSHORTENED=2

    # How many character to reduce shortened directories to.
    SHORT_LENGTH=2

    # Get unshortened directories.
    UNSHORTENED_DIRS=`echo $DIRS | tail -n $UNSHORTENED`

    # If the unshortened directories are all of them, don't bother with the rest.
    if [[ `echo $DIRS | wc -l` -le $UNSHORTENED ]]; then
        echo -n $UNSHORTENED_DIRS | tr '\n' '/'
        return
    fi

    # Get all pieces that need to be shortened.
    SHORTENED_DIRS=`echo $DIRS | cut -c-$SHORT_LENGTH | head -n-$UNSHORTENED`

    # Print out the directory. Make sure not to include trailing /, which is why we cut off that newline using head.
    # head used to be ghead
    (echo $SHORTENED_DIRS; echo $UNSHORTENED_DIRS | head -c-1) | tr '\n' '/'
}
prompt_cwd='$(working_dir)'

# Display whether prediction is enabled or disabled.
function prediction_enabled {
    if [[ $NEXT_PREDICT_STATE == "predict-off" ]]; then
        echo -n "[!!!]"
    else
        echo -n "[___]"
    fi
}
prediction_indicator='$(prediction_enabled)'

function zle-keymap-select {
    CURRENT_KEYMAP=$KEYMAP
    zle reset-prompt
}
zle -N zle-keymap-select

function vimode_color {
    if [[ $CURRENT_KEYMAP == "vicmd" ]]; then
        echo -n $bold_cyan
    else
        echo -n $bold_blue
    fi
}
vimode='$(vimode_color)'

# The final prompt! Ain't it adorable?
PROMPT="$exit_code_color$vimode$prediction_indicator$color_reset$exit_color $cur_time $prompt_user $prompt_cwd "'$(prompt_char)'" $color_reset"

### }

### Zsh mime types for opening files ###
### {

autoload zsh-mime-setup && zsh-mime-setup
zstyle ':mime:*' flags needsterminal

# Set up mime types
for ext in xls ods odf;            do alias -s $ext=open; done
for ext in djvu ps;           do alias -s $ext=open; done
alias -s pdf='open -a Skim'

### }

### Setting the terminal title. ###
### {

function title() {
  # escape '%' chars in $1, make nonprintables visible
  a=${(V)1//\%/\%\%}

  # Truncate command, and join lines.
  a=$(print -Pn "%40>...>$a" | tr -d "\n")

  case $TERM in
  screen)
    print -Pn "\ek$a:$3\e\\"      # screen title (in ^A")
    ;;
  xterm*|rxvt)
    print -Pn "\e]2;$2 | $a:$3\a" # plain xterm title
    ;;
  esac
}

# precmd is called just before the prompt is printed
function precmd() {
  title "zsh" "%55<...<%~"
}

# preexec is called just before any command line is executed
function preexec() {
  title "$1" "%35<...<%~"
}
### }

### File system mark-jump ###
### {
export MARKPATH=$HOME/.marks
function jump { 
    cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}
function mark { 
    mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}
function unmark { 
    rm -i "$MARKPATH/$1"
}
function marks {
    ls -l "$MARKPATH" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
}

create-mark () {
    # Create a new mark in this directory.
    read -k MARK_NAME
    mark $MARK_NAME
}
zle -N create-mark

jump-to-mark () {
    # Jump to the mark.
    read -k MARK_NAME
    jump $MARK_NAME
    zle reset-prompt
}
zle -N jump-to-mark

up-one-dir () {
    builtin cd ..
    zle reset-prompt
    POSTDISPLAY=`echo && lp -C`
}
zle -N up-one-dir

show-contents () {
    POSTDISPLAY=`echo && lp -C`
}
zle -N show-contents

bindkey -M vicmd 'm' create-mark
bindkey -M vicmd "'" jump-to-mark
bindkey -M vicmd 'u' up-one-dir
bindkey -M vicmd 's' show-contents
###}

### Keybindings ###
### {

# Create a custom widget for searching within the command-line.
autoload -U read-from-minibuffer
do-search () {
    # First argument $1 is the search query.
    # Second argument $2 is the start character.

    # Record previous position.
    PREV_CURSOR=$CURSOR
    
    # Cut off first characters to not search them.
    TEXT=`echo $BUFFER | sed -r "s/^.{$2}//"`

    # Do search, count characters before the search query.
    CURSOR=`echo $TEXT | sed -n "s/$1.*$//p" | wc -c`

    # Switch to zero-indexed cursor position.
    ((CURSOR = CURSOR - 1))

    # Add in the cut off characters.
    ((CURSOR = CURSOR + $2))

    # If position hasn't changed, increment by one and repeat. This avoids the
    # problem where pressing 'n' after a search doesn't do anything because it
    # just finds the same search pattern in the sample place.
    if ((PREV_CURSOR == CURSOR)); then
        ((INC_CURSOR = CURSOR + 1))
        do-search "$1" $INC_CURSOR
    fi
}

inline-search () {
    # Read the variable REPLY from the minibuffer. This is the search pattern.
    local REPLY
    read-from-minibuffer "/"

    # If we get a search pattern, do the search.
    if [ -n $REPLY ]; then
        # Start the search at the beginning of the command line.
        do-search "$REPLY" 0

        # Store the previous search so that we can repeat it.
        ZSH_LAST_INLINE_SEARCH="$REPLY"
    fi
}

repeat-inline-search () {
    # Repeat the previous search, starting from the current cursor position.
    do-search "$ZSH_LAST_INLINE_SEARCH" $CURSOR
}
zle -N inline-search
zle -N repeat-inline-search

function clear-screen {
    zle -I
    repeat $((LINES - 1)) echo "\n"
    clear
}
zle -N clear-screen

# Switch to the vim keymap.
bindkey -v

# History searches with k/j, incremental with ?
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
bindkey -M vicmd '?' history-incremental-search-backward
bindkey -M viins '^r' history-incremental-search-backward

# (Custom) inline searching.
bindkey -M vicmd '/' inline-search
bindkey -M vicmd 'n' repeat-inline-search

# Emacs-style keybindings.
bindkey -M viins '^a' beginning-of-line
bindkey -M vicmd '^a' beginning-of-line
bindkey -M viins '^e' end-of-line
bindkey -M vicmd '^e' end-of-line
bindkey -M viins '^k' kill-line
bindkey -M vicmd '^k' kill-line
bindkey -M viins '^l' clear-screen
bindkey -M vicmd '^l' clear-screen

# Prediction completions
autoload predict-on && predict-on && zle -N predict-on
autoload predict-off && zle -N predict-off
zstyle :predict cursor key
zstyle ':completion:predict:*' completer _oldlist _complete _ignored _history _prefix

# Press enter to only execute what we have so far; press C-J to execute all.
run-line () {
    if [[ $NEXT_PREDICT_STATE == "predict-off" ]]; then
        zle vi-kill-eol
        zle accept-line
    else
        zle accept-line
    fi

    # Turn on prediction after each command.
    yes-predict
}
zle -N run-line
bindkey '^M' run-line

# Disable prediction sometimes with C-z.
NEXT_PREDICT_STATE="predict-off"
toggle-predict() {
    zle $NEXT_PREDICT_STATE
    if [[ $NEXT_PREDICT_STATE == "predict-off" ]]; then
        NEXT_PREDICT_STATE="predict-on"
    else
        NEXT_PREDICT_STATE="predict-off"
    fi
    zle reset-prompt

    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
}
zle -N toggle-predict
bindkey -M viins '^z' toggle-predict
bindkey -M vicmd '^z' toggle-predict

# Disable prediction on Ctrl-a or h or b.
# Re-enable with Ctrl-e.
no-predict() {
    zle predict-off
    NEXT_PREDICT_STATE="predict-on"
    zle reset-prompt
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
}
yes-predict() {
    zle predict-on
    NEXT_PREDICT_STATE="predict-off"
    zle reset-prompt
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
}

go-back-letter() {
    zle vi-backward-char
    no-predict
}
go-back-word() {
    zle vi-backward-word
    no-predict
}
go-back-line() {
    zle vi-beginning-of-line
    no-predict
}
go-forward-line() {
    zle vi-end-of-line
    yes-predict
}

zle -N go-back-letter
zle -N go-back-word
zle -N go-back-line
zle -N go-forward-line

bindkey -M vicmd 'h' go-back-letter
bindkey -M vicmd 'b' go-back-word
bindkey -M vicmd '^a' go-back-line
bindkey -M viins '^a' go-back-line
bindkey -M vicmd '^e' go-forward-line
bindkey -M viins '^e' go-forward-line
### }

### Aliases and miscellaneous ###
### {

# Computer specific customizations.
if test `uname -n` "==" "vortex" "-o" `uname -n` "==" "sourcery.local"; then
    ###########################
    #### Home / Work Macs. ####
    ###########################

    # Get rid of undeleteable directories.
    alias l='gls --color --hide=Documents  --hide=Movies  --hide=Music  --hide=Pictures  --hide=Public --hide=Library --hide=Desktop --hide=Applications'
    alias ls='gls --color --hide=Documents  --hide=Movies  --hide=Music  --hide=Pictures  --hide=Public --hide=Library --hide=Desktop --hide=Applications'
    alias lp='gls --color=none --hide=Documents  --hide=Movies  --hide=Music  --hide=Pictures  --hide=Public --hide=Library --hide=Desktop --hide=Applications'

    export MANPATH="/Users/silver/dev/homebrew/opt/coreutils/libexec/gnuman:$MANPATH"

    # Shortcut to screenshots.
    export SC=/Users/silver/downloads/screenshots
    alias mvsc='mv $SC/*.png'

    # Make pip work on mavericks.
    export ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future

    # Let LaTeX use my custom installs and classes.
    export TEXINPUTS=$TEXINPUTS:/Users/silver/code/dotfiles/latex

    # Brew provisioning: run this to get a list of commands
    alias brew-provision='~/code/dotfiles/utils/brew-packages ~/code/dotfiles/packages ~/code/dotfiles/casks'
else
    eval `dircolors -b`
    alias ls='=ls --color'
    alias lp='=ls --color=none'
    alias l='=ls --color'

    if test "-f" "$HOME/.karius.sh"; then
        source $HOME/.karius.sh
    fi
fi
alias la='l -a'
alias ll='l -l'

# I always type this!
alias duh='du -h --summarize'

# Extended history viewing.
alias history='history 0'

# Have a global notes file.
alias notes='vim ~/.notes'
alias day='vim ~/.text/`date +%b-%d`'
alias vim='nvim'
alias vi='nvim'
export NVIM_TUI_ENABLE_TRUE_COLOR=1

function hi {
    pbpaste | highlight -O rtf --syntax=$1 --style=edit-vim | pbcopy
}

# Trim images.
function trim () {
    convert $1 -trim $1;
}

# Command to plan all the mp3 files in the current directory as an mplayer playlist, sorted randomly.
function music-random () {
    bash -c "mplayer `ls --color=none -Q | sort -R | sed 's/"$/" \\\\/g' | grep -v '\`'`"
}

# Convenient grep killer.
function grepkill () {
    kill `ps aux | grep $1 | cut -d ' ' -f 5`
}

# Start chrome in incognito mode.
alias incognito='google-chrome --incognito'

# Run a matlab terminal by default. Use =matlab for normal GUI.
alias matlab='matlab -nodesktop -nosplash'

# Cleaner aliases for removing temp files.
alias latexclean='rm *.log *.aux *.pyg *.bbl *.blg *.out 2> /dev/null'
alias haskellclean='rm *.o *.hi 2> /dev/null'
alias beamerclean='rm *.out *.log *.aux *.nav *.snm *.toc *.vrb 2> /dev/null'

# Activate the virtualenv environment given.
function activate {
    source $1/bin/activate
}

# If there is anv 'env' in my home, go ahead and load it.
if [[ -d ~/env ]]; then
    activate ~/env
fi

# Nice aliases for common commandline tasks.
alias -g @='&> /dev/null &!'
alias -g %='2>&1 | less'
alias -g %h=' | head'
alias -g %v=' | vim -'
alias -g %t=' | tail'

alias untar='tar -xvvf'
alias grep='grep --color=auto'
alias br='=git branch'
alias sw='=git checkout'
alias cm='=git commit'
alias pu='=git push origin'
alias pull='=git pull origin'
alias mplayer='=mplayer -af scaletempo'

# Make git autocompletion of branches not-painfully-slow.
__git_files () { 
    _wanted files expl 'local files' _files 
}

# Python startup files.
export PYTHONSTARTUP=$HOME/.pythonrc.py

# Go up directories easily.
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'

# Exit with external editor.
autoload edit-command-line 
zle -N edit-command-line
bindkey -M vicmd 'q' edit-command-line

# Text me command.
function text-me {
    curl http://textbelt.com/text -d number=$((3015253100 - 100 + 37 * 2)) -d "message=$1"
}

### }

### Foreign modules ###
### {
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh/zle_vi_visual.zsh

# Load fasd and my fasd shortcuts.
eval "$(fasd --init posix-alias zsh-hook zsh-wcomp zsh-wcomp-install)"
alias v='fasd -f -e vim'
alias j='fasd_cd -d'
bindkey '^t' fasd-complete

### }
