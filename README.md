Installation
============

In order to make this setup functional on any Linux or Mac computer, execute the following commands:

```bash
# I rely on things being in ~/code/dotfiles to make links.
git clone http://www.github.com/gibiansky/dotfiles $HOME/code/dotfiles

# Run setup.
$HOME/code/dotfiles/init.sh
```

After that, make sure that when your .vimrc is being loaded, the HOME environment variable is defined, because vim uses it to find other files.
