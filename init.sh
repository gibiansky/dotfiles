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

# Make place for temp files and backup for vim.
mkdir -p $HOME/.vim/tmp/backup

# Set up the ~/.vimrc to point to my configuration.
echo 'source ~/.vim/configuration.vim' > ~/.vimrc

# Install Vundle.
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

# Make sure we're using zsh, not bash.
chsh -s zsh
