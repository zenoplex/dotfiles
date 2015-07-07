#!/bin/bash


# to maintain cask .... 
# brew update && brew upgrade brew-cask && brew cleanup && brew cask cleanup`


# Install native apps

brew install caskroom/cask/brew-cask
brew tap caskroom/versions

# daily
brew cask install spectacle
brew cask install dropbox
brew cask install skitch
brew cask install onepassword
brew cask install rescuetime
brew cask install flux
brew cask install bettersnaptool
brew cast install totalfinder

# dev
brew cask install iterm2
brew cask install sublime-text
brew cask install atom
brew cask install webstorm
brew cask install imageoptim
brew cask install charles

# vms
brew cask install virtualbox
brew cask install genymotion

# fun
brew cask install miro-video-converter
brew cask install adobe-photoshop-lightroom

# browsers
brew cask install google-chrome-canary
brew cask install firefox-nightly
brew cask install webkit-nightly
brew cask install chromium
brew cask install torbrowser

# less often
brew cask install disk-inventory-x
brew cask install vlc
brew cask install licecap


# Appstore

## BetterSnapTool
## Slack
## Line
## Transmit
