DOTFILES := $(CURDIR)/dotfiles
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
# Skips if the destination already links to the source. Anything else at the
# destination is moved under ~/.dotfiles-backup/<timestamp>/ before linking.
# Creates parent directories as needed.
define LINK_FN
backup_root="$(HOME)/.dotfiles-backup/$$(date +%Y%m%d-%H%M%S)-$$$$"; \
link () { \
	src="$$1"; dst="$$2"; \
	if [ ! -e "$$src" ]; then \
		echo "skipped $$dst (missing source: $$src)"; \
		return; \
	fi; \
	if [ -L "$$dst" ] && [ "$$(readlink "$$dst")" = "$$src" ]; then \
		echo "skipped $$dst (already linked)"; \
		return; \
	fi; \
	if [ -e "$$dst" ] || [ -L "$$dst" ]; then \
		backup="$$backup_root/$${dst#$(HOME)/}"; \
		mkdir -p "$$(dirname "$$backup")"; \
		mv "$$dst" "$$backup"; \
		echo "backed up $$dst to $$backup"; \
	fi; \
	mkdir -p "$$(dirname "$$dst")"; \
	ln -s "$$src" "$$dst"; \
	echo "linked $$dst -> $$src"; \
}
endef

.PHONY: install
install: symlink install_brew install_brew_packages install_mise_tools
	@echo "NOTE: after Obsidian is installed and the vault is synced, run: make symlink_agents"

# These dotfiles assume Homebrew at /opt/homebrew. uname -m reports x86_64 under
# Rosetta, where Homebrew refuses to install, so that fails here too.
.PHONY: check_arch
check_arch:
	@if [ "$$(uname -m)" != arm64 ]; then \
		echo "ERROR: these dotfiles support Apple Silicon Macs only (not Intel or a Rosetta shell)"; \
		exit 1; \
	fi

# Symlink dotfiles
.PHONY: symlink
symlink: check_arch
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
install_brew: check_arch
	@if command -v brew >/dev/null 2>&1 || [ -x /opt/homebrew/bin/brew ]; then \
		echo "Homebrew is installed."; \
	else \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi

# Install Homebrew packages
.PHONY: install_brew_packages
install_brew_packages: install_brew
	"$$(command -v brew || echo /opt/homebrew/bin/brew)" bundle --file="$(DOTFILES)/Brewfile"

# Install the tools in ~/.config/mise/config.toml. mise only auto-installs from an
# activated interactive shell, so a fresh machine would have no bun or node yet.
.PHONY: install_mise_tools
install_mise_tools: symlink install_brew_packages
	"$$(command -v mise || echo /opt/homebrew/bin/mise)" install
