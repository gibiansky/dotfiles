Installation
============

In order to make this setup functional on any Linux computer, download this repository and execute the following commands:

```bash
# Rename to .vim
mv dotfiles ~/.vim

# Make links to the configuration files from your home folder
echo 'source ~/.vim/configuration.vim' > ~/.vimrc
ln -s ~/.vim/foreign/zsh.config ~/.zshrc

# Switch to zsh instead of bash
chsh -s zsh

# Decompress Java resources
cd ~/.vim/resources/java
tar -xvf api.tar.gz
cd

# Install Vundle
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

# Create backup and swap file directories for Vim
mkdir -p ~/.vim/tmp/backup
```

After that, make sure that when your .vimrc is being loaded, the HOME environment variable is defined, because vim uses it to find other files.

If you prefer a different color scheme, replace ~/.vim/colorscheme.vim with one of your own choice.

Shortcuts and Features
=========

`tmux` Features:
- Use `C-x` as the prefix key
- Use `vim` keybindings
- Default to `/bin/zsh`

`tmux` Shortcuts (prefixed by `C-x`):

- `C-v`: vertical split
- `C-s`: horizontal split
- `C-[hjkl]`: move to left, down, up, and right panes, respectively
- `M-[arrow key]`: resize the pane you're in (can be repeated quickly with many applications)
- `:`: prompt
