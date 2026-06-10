PWD := $(shell pwd)
DOTFILES := $(PWD)/dotfiles
-include Makefile.local

MANAGED_LINKS := \
	$(DOTFILES)/.zshrc::$(HOME)/.zshrc \
	$(DOTFILES)/.gitconfig::$(HOME)/.config/git/config \
	$(DOTFILES)/.gitignore::$(HOME)/.config/git/ignore \
	$(DOTFILES)/.gitmessage.txt::$(HOME)/.config/git/message \
	$(DOTFILES)/starship.toml::$(HOME)/.config/starship.toml \
	$(DOTFILES)/mise/config.toml::$(HOME)/.config/mise/config.toml \
	$(DOTFILES)/.claude/settings.json::$(HOME)/.claude/settings.json

# Shared shell function: link <src> <dst>
# Skips if the destination already exists; creates parent directories as needed.
define LINK_FN
link () { \
	src="$$1"; dst="$$2"; \
	if [ ! -e "$$src" ]; then \
		echo "skipped $$dst (missing source: $$src)"; \
		return; \
	fi; \
	if [ -e "$$dst" ] || [ -L "$$dst" ]; then \
		echo "skipped $$dst (already exists)"; \
		return; \
	fi; \
	mkdir -p "$$(dirname "$$dst")"; \
	ln -s "$$src" "$$dst"; \
	echo "linked $$dst -> $$src"; \
}
endef

.PHONY: install
install: symlink install_brew install_brew_packages
	@echo "NOTE: after Obsidian is installed and the vault is synced, run: make symlink_agents"

# Symlink dotfiles
.PHONY: symlink
symlink:
	@$(LINK_FN); \
	for pair in $(MANAGED_LINKS); do \
		link "$${pair%%::*}" "$${pair#*::}"; \
	done; \
	echo "Symlinked dotfiles."

# Symlink agent files from the Obsidian vault (run after Obsidian is set up)
.PHONY: symlink_agents
symlink_agents:
ifndef OBSIDIAN_CLAUDE
	@echo "ERROR: OBSIDIAN_CLAUDE is not set"
	@echo "Create a Makefile.local file with:"
	@echo "  OBSIDIAN_CLAUDE = /path/to/your/obsidian/claude"
	@exit 1
endif
	@if [ ! -d "$(OBSIDIAN_CLAUDE)" ]; then \
		echo "ERROR: $(OBSIDIAN_CLAUDE) does not exist (install Obsidian and sync the vault first)"; \
		exit 1; \
	fi; \
	$(LINK_FN); \
	for d in "$(OBSIDIAN_CLAUDE)/skills"/*; do \
		[ -d "$$d" ] || continue; \
		name="$${d##*/}"; \
		link "$$d" "${HOME}/.claude/skills/$$name"; \
		link "$$d" "${HOME}/.agents/skills/$$name"; \
	done; \
	link "$(OBSIDIAN_CLAUDE)/AGENTS.md" "${HOME}/.claude/CLAUDE.md"; \
	link "$(OBSIDIAN_CLAUDE)/AGENTS.md" "${HOME}/.codex/AGENTS.md"; \
	echo "Symlinked agent files."

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
