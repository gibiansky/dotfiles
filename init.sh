#!/bin/bash

# Exit on undefined variable usage.
set -u

# All files we want to re-alias.
FILES="vim tmux.conf vimperatorrc zsh zshrc slate pythonrc.py"

# Aliases for files.
for FILE in $FILES; do
    ln -s $HOME/code/dotfiles/$FILE $HOME/.$FILE;
done

# Make place for temp files and backup for vim.
mkdir -p $HOME/.vim/tmp/backup

# Set up the ~/.vimrc to point to my configuration.
echo 'source ~/.vim/configuration.vim' > ~/.vimrc

# Install Vundle.
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Make sure we're using zsh, not bash.
# Assume Homebrew provides zsh.
chsh -s /usr/local/bin/zsh
