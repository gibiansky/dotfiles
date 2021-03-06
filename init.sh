#!/bin/bash

# Exit on undefined variable usage.
set -u

# All files we want to re-alias.
FILES="hushlogin vim tmux.conf zsh zshrc pythonrc.py hammerspoon"

# Aliases for files.
for FILE in $FILES; do
    ln -s $HOME/code/dotfiles/$FILE $HOME/.$FILE;
done

# Make place for temp files and backup for vim.
mkdir -p $HOME/.vim/tmp/backup

# Set up the ~/.vimrc to point to my configuration.
echo 'source ~/.vim/configuration.vim' > ~/.vimrc
echo 'source ~/.vim/configuration.vim' > ~/.nvimrc
echo 'source ~/.vim/configuration.vim' > ~/.config/nvim/init.vim

# Install Vundle.
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Install Oh-My-Zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

# Install Oh-My-Zsh custom plugins.
git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone git://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Install all Vundle plugins.
vim +PluginInstall +qall
