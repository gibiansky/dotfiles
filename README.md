Installation
============

In order to make this setup functional on any Linux or Mac computer, execute the following commands:

```bash
# I rely on things being in ~/code/dotfiles to make links.
mkdir -p $HOME/code
git clone http://www.github.com/gibiansky/dotfiles $HOME/code/dotfiles

# Run setup.
$HOME/code/dotfiles/init.sh

# Set up Oh-My-Zsh.
git clone https://github.com/robbyrussell/oh-my-zsh $HOME/.oh-my-zsh
source ~/.zshrc # Make sure $ZSH_CUSTOM is set
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
     ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions \
    $ZSH_CUSTOM/plugins/zsh-autosuggestions
```

# Mac Configuration

I need to set up the environment with `brew`:
```bash
# Download homebrew, as recommended, sketchily
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Tap relevant things
brew tap caskroom/cask
brew tap homebrew/versions
brew tap homebrew/science

# Run all commands for brew provisioning
brew-provision
```

Then make sure we default to the right shell:
```bash
# Make sure we're using zsh, not bash.
chsh -s `brew --prefix`/bin/zsh
```

More configurations:

- **Karabiner-Elements:**
    - Caps Lock should be set to Esc (keycode 53)
    - Right Command (Command_R) should be set to Alt (keycode 61)
    - Escape should be set to Home (keycode 109)
- **iTerm:**
    - Set the Hotkey Window to use Home

After that, make sure that when your .vimrc is being loaded, the HOME environment variable is defined, because vim uses it to find other files.
