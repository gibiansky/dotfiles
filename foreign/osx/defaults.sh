#!/bin/bash -x

### Set Defaults ###

# Write screenshots into a Downloads subdirectory.
defaults write com.apple.screencapture location ~/Downloads/screenshots

# Show location bar in Finder.
defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES

### Restart relevant services ###
killall Finder
killall SystemUIServer
