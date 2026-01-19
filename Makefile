PWD := $(shell pwd)
DOTFILES := $(PWD)/dotfiles
-include Makefile.local

.PHONY: install
install: make_dir symlink install_brew install_brew_packages

# Make directory if not exist
.PHONY: make_dir
make_dir:
	mkdir -p ${HOME}/.config/git
	mkdir -p ${HOME}/.config/mise
	mkdir -p ${HOME}/.claude
	mkdir -p ${HOME}/.claude/plugins

# Symlink dotfiles
.PHONY: symlink
symlink: \
	${HOME}/.zshrc \
	${HOME}/.config/git/config \
	${HOME}/.config/git/ignore \
	${HOME}/startship \
	${HOME}/.config/mise/config.toml \
	${HOME}/.claude/settings.json \
	${HOME}/.claude/statusline.sh \
	symlink_obsidian_claude \
	symlink_done

${HOME}/.zshrc:
	ln -fs $(DOTFILES)/.zshrc $@

${HOME}/.config/git/config:
	ln -fs $(DOTFILES)/.gitconfig $@

${HOME}/.config/git/ignore:
	ln -fs $(DOTFILES)/.gitignore $@

${HOME}/startship:
	ln -fs $(DOTFILES)/startship.toml ${HOME}/.config/starship.toml

${HOME}/.config/mise/config.toml:
	ln -fs $(DOTFILES)/mise/config.toml $@

${HOME}/.claude/settings.json:
	ln -fs $(DOTFILES)/.claude/settings.json ${HOME}/.claude/settings.json

${HOME}/.claude/statusline.sh:
	ln -fs $(DOTFILES)/.claude/statusline.sh ${HOME}/.claude/statusline.sh


.PHONY: symlink_obsidian_claude
symlink_obsidian_claude:
ifndef OBSIDIAN_CLAUDE
	@echo "ERROR: OBSIDIAN_CLAUDE is not set"
	@echo "Create a Makefile.local file with:"
	@echo "  OBSIDIAN_CLAUDE = /path/to/your/obsidian/claude"
	@exit 1
endif
	@ln -fs $(OBSIDIAN_CLAUDE)/agents ${HOME}/.claude/agents
	@ln -fs $(OBSIDIAN_CLAUDE)/skills ${HOME}/.claude/skills
	@ln -fs $(OBSIDIAN_CLAUDE)/marketplaces ${HOME}/.claude/plugins/marketplaces
	@ln -fs $(OBSIDIAN_CLAUDE)/AGENTS.md ${HOME}/.claude/CLAUDE.md

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
