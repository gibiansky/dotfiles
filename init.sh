#!/bin/bash

# Exit on undefined variable usage.
set -u

# All files we want to re-alias.
FILES="vim tmux.conf vimperatorrc zsh zshrc slate pythonrc.py hammerspoon"

# Aliases for files.
for FILE in $FILES; do
    ln -s $HOME/code/dotfiles/$FILE $HOME/.$FILE;
done

# Make place for temp files and backup for vim.
mkdir -p $HOME/.vim/tmp/backup

# Set up the ~/.vimrc to point to my configuration.
echo 'source ~/.vim/configuration.vim' > ~/.vimrc
echo 'source ~/.vim/configuration.vim' > ~/.nvimrc

# Install Vundle.
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Install all Vundle plugins.
vim +PluginInstall +qall
