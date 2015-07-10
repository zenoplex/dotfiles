# copy paste this file in bit by bit.
# don't run it.
  echo "do not run this script in one go. hit ctrl-c NOW"
  read -n 1

##
##  migration from old machine
##

mkdir -p ~/migration/home
cd ~/migration

# what is worth reinstalling
brew leaves      		> brew-list.txt    # all top-level brew installs
brew cask list 			> cask-list.txt
npm list -g --depth=0 	> npm-g-list.txt

# then compare brew-list to what's in `brew.sh`
#   comm <(sort brew-list.txt) <(sort brew.sh-cleaned-up)

# let's hold on to these

cp ~/.extra ~/migration/home

cp -R ~/.ssh ~/migration/home

cp /Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist ~/migration  # wifi

cp -R ~/Library/Services ~/migration # automator stuff

cp -R ~/Documents ~/migration


# Current Chrome tabs via OneTab

# iTerm settings.
  # Prefs, General, Use settings from Folder

# Finder settings and TotalFinder settings
#   Not sure how to do this yet. Really want to.



##
## new machine setup.
##


#
# homebrew!
#
# (google machines are funny so i have to do this. everyone else should use the regular thang)
mkdir $HOME/.homebrew && curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C $HOME/.homebrew
export PATH=$HOME/.homebrew/bin:$HOME/.homebrew/sbin:$PATH
#
# install all the things
./brew.sh

# install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

npm install -g git-open
npm install -g npm-check-updates
npm install -g browser-sync
npm install -g yo
npm install -g gulp
npm install -g less2sass
npm install -g html2jade
npm install -g surge


# github.com/rupa/z   - oh how i love you
# chmod +x ~/code/z/z.sh
# consider reusing your current .z file if possible. it's painful to rebuild :)
# z use as plugin in oh-my-zsh

# github.com/thebitguru/play-button-itunes-patch
# disable itunes opening on media keys
git clone https://github.com/thebitguru/play-button-itunes-patch ~/code/play-button-itunes-patch

# my magic photobooth symlink -> dropbox. I love it.
#  + first move Photo Booth folder out of Pictures
#  + then start Photo Booth. It'll ask where to put the library.
#  + put it in Dropbox/public
# * Now… you can record photobooth videos quickly and they upload to dropbox DURING RECORDING
# * then you grab public URL and send off your video message in a heartbeat.

# for the c alias (syntax highlighted cat)
sudo easy_install Pygments

# iterm with more margin! http://hackr.it/articles/prettier-gutter-in-iterm-2/

# software licenses like sublimetext

# setting up the sublime symlink
ln -sf "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ~/bin/subl

# go read mathias, paulmillr, gf3, alraa's dotfiles to see what to update with.

# set up osx defaults
#   maybe something else in here https://github.com/hjuutilainen/dotfiles/blob/master/bin/osx-user-defaults.sh
sh .osx

# symlinks!
#   put/move git credentials into ~/.gitconfig.local
#   http://stackoverflow.com/a/13615531/89484
./symlink-setup.sh
