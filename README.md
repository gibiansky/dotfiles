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

# Mac Configuration

I need to set up the environment with `brew`:
```bash
# Download homebrew, as recommended, sketchily
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Tap relevant things
brew tap caskroom/cask
brew tap homebrew/versions
brew tap homebrew/x11
brew tap neovim/neovim
brew tap homebrew/php
brew tap homebrew/science
brew tap caskroom/versions

# Run all commands for brew provisioning
brew-provision
```

Then make sure we default to the right shell:
```bash
# Make sure we're using zsh, not bash.
chsh -s `brew --prefix`/bin/zsh
```

More configurations:

- **Seil:**
    - Caps Lock should be set to Esc (keycode 53)
    - Right Command (Command_R) should be set to Alt (keycode 61)
    - Escape should be set to F-10 (keycode 109)
- **iTerm:**
    - Deal with neovim's idiocy, though check if this is still necessary (neovim changes quickly). In `Profiles > Default > Keys`, add `^h` to `Send Hex Code: 0x89`
- **Alfred:**
    - Alfred Hotkey: Alt double tap

After that, make sure that when your .vimrc is being loaded, the HOME environment variable is defined, because vim uses it to find other files.
