PWD := $(shell pwd)
DOTFILES := $(PWD)/dotfiles

.PHONY: install
install: make_dir symlink install_brew install_brew_packages

# Make directory if not exist
.PHONY: make_dir
make_dir:
	mkdir -p ${HOME}/.config/git
	mkdir -p ${HOME}/.config/mise
	mkdir -p ${HOME}/.claude

# Symlink dotfiles
.PHONY: symlink
symlink: \
	${HOME}/.zshrc \
	${HOME}/.gitconfig \
	${HOME}/.gitignore \
	${HOME}/startship \
	${HOME}/.mise \
	${HOME}/.claude/skills \
	${HOME}/.claude/settings.json \
	${HOME}/.claude/statusline.sh \
	${HOME}/.claude/CLAUDE.md \
	symlink_done

${HOME}/.zshrc:
	ln -fs $(DOTFILES)/.zshrc ${HOME}/.zshrc

${HOME}/.gitconfig:
	ln -fs $(DOTFILES)/.gitconfig ${HOME}/.config/git/config

${HOME}/.gitignore:
	ln -fs $(DOTFILES)/.gitignore ${HOME}/.config/git/ignore

${HOME}/startship:
	ln -fs $(DOTFILES)/startship.toml ${HOME}/.config/starship.toml

${HOME}/.mise:
	ln -fs $(DOTFILES)/mise/config.toml ${HOME}/.config/mise/config.toml

${HOME}/.claude/skills:
	rm -rf ${HOME}/.claude/skills
	ln -s $(DOTFILES)/.claude/skills ${HOME}/.claude/skills

${HOME}/.claude/settings.json:
	ln -fs $(DOTFILES)/.claude/settings.json ${HOME}/.claude/settings.json

${HOME}/.claude/statusline.sh:
	ln -fs $(DOTFILES)/.claude/statusline.sh ${HOME}/.claude/statusline.sh

${HOME}/.claude/CLAUDE.md:
	ln -fs $(DOTFILES)/.claude/CLAUDE.md ${HOME}/.claude/CLAUDE.md

symlink_done:
	@echo "Symlinked dotfiles."

# Install Homebrew
.PHONY: install_brew
BREW := $(shell command -v brew 2>/dev/null)
install_brew:
ifdef BREW
	@echo "Homebrew is installed."
else
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
endif

# Install Homebrew packages
.PHONY: install_brew_packages
install_brew_packages:
	brew bundle --file=$(DOTFILES)/Brewfile
