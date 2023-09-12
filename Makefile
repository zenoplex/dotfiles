PWD := $(shell pwd)
DOTFILES := $(PWD)/dotfiles

.PHONY: install
install: symlink install_brew

.PHONY: symlink
symlink: \
	${HOME}/.zshrc \
	${HOME}/.gitconfig \
	${HOME}/startship \
	symlink_done

${HOME}/.zshrc:
	ln -fs $(DOTFILES)/.zshrc ${HOME}/.zshrc

${HOME}/.gitconfig:
	ln -fs $(DOTFILES)/.gitconfig ${HOME}/.gitconfig

${HOME}/startship:
	ln -fs $(DOTFILES)/startship.toml ${HOME}/.config/starship.toml

symlink_done:
	@echo "Symlinked dotfiles."


.PHONY: install_brew
BREW := $(shell command -v brew 2>/dev/null)
install_brew:
ifdef BREW
	@echo "Homebrew is installed."
else
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
endif

.PHONY: install_brew_packages
install_brew_packages:
	brew bundle --file=$(DOTFILES)/Brewfile
	