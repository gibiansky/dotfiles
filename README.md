Installation
============

In order to make this setup functional on any Linux or Mac computer, execute the following commands:

```bash
# I rely on things being in ~/code/dotfiles to make links.
mkdir -p $HOME/code
git clone http://www.github.com/gibiansky/dotfiles $HOME/code/dotfiles

# Run setup.
$HOME/code/dotfiles/init.sh
```

If I'm using a Mac, I need to set up the environment with `brew`:
```bash
# Download homebrew, as recommended, sketchily
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Run all commands for brew provisioning
brew-provision
```

Then make sure we default to the right shell:
```bash
# Make sure we're using zsh, not bash.
chsh -s `brew --prefix`/bin/zsh
```

After that, make sure that when your .vimrc is being loaded, the HOME environment variable is defined, because vim uses it to find other files.
