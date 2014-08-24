#!/bin/bash

# Exit on undefined variable usage.
set -u

# All files we want to re-alias.
FILES="vim tmux.conf vimperatorrc zsh zshrc slate pythonrc.py"

# Aliases for files.
for FILE in $FILES; do
    rm -f $HOME/.$FILE;
    ln -s $HOME/.$FILE $HOME/code/dotfiles/$FILE;
done
