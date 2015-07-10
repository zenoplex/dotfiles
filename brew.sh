#!/bin/bash

brew update
brew upgrade

# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
# GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
brew install findutils
brew install wget --enable-iri

brew install zsh
brew tap homebrew/dupes
brew install homebrew/dupes/grep
brew install ack
brew install git
brew install tree

brew install openssl
brew install php54-mcrypt
brew install optipng
brew install redis
brew install mysql
brew install phpunit
brew install postgresql

brew install gh
brew install nodebrew
brew install rbenv
brew install ruby-build
brew install heroku-toolbelt

# cask
# brew update && brew upgrade brew-cask && brew cleanup && brew cask cleanup`

brew install caskroom/cask/brew-cask
brew tap caskroom/versions

brew cask install spectacle
brew cask install dropbox
brew cask install skitch
brew cask install 1password
brew cask install rescuetime
brew cask install totalfinder

brew cask install iterm2
brew cask install sublime-text
brew cask install atom
brew cask install webstorm
brew cask install imageoptim
brew cask install charles

brew cask install virtualbox
brew cask install genymotion
brew cask install vagrant

brew cask install miro-video-converter
brew cask install adobe-photoshop-lightroom

brew cask install google-chrome-canary
brew cask install firefox-nightly
brew cask install webkit-nightly
brew cask install chromium

brew cask install vlc
brew cask install licecap

# Appstore

## BetterSnapTool
## Slack
## Line
## Transmit

brew cleanup
