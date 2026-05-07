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

.PHONY: install
install: make_dir symlink install_brew install_brew_packages

# Make directory if not exist
.PHONY: make_dir
make_dir:
	mkdir -p ${HOME}/.config/git
	mkdir -p ${HOME}/.config/mise
	mkdir -p ${HOME}/.claude
	mkdir -p ${HOME}/.claude/plugins
	mkdir -p ${HOME}/.claude/skills
	mkdir -p ${HOME}/.agents/skills
	mkdir -p ${HOME}/.codex

# Symlink dotfiles
.PHONY: symlink
symlink: \
	_managed_symlink \
	symlink_obsidian_claude \
	symlink_done

.PHONY: _managed_symlink
_managed_symlink:
	@status=0; ok_count=0; linked_count=0; failed_count=0; \
	for link in $(MANAGED_LINKS); do \
		src="$${link%%::*}"; dst="$${link#*::}"; \
		if [ ! -e "$$src" ]; then \
			echo "failed $$dst (missing source: $$src)"; \
			status=1; failed_count=$$((failed_count + 1)); \
			continue; \
		fi; \
		mkdir -p "$$(dirname "$$dst")"; \
		if [ -L "$$dst" ]; then \
			current="$$(readlink "$$dst")"; \
			if [ "$$current" = "$$src" ]; then \
				echo "ok $$dst -> $$src"; \
				ok_count=$$((ok_count + 1)); \
				continue; \
			fi; \
			rm "$$dst"; \
			ln -s "$$src" "$$dst"; \
			echo "linked $$dst -> $$src"; \
			linked_count=$$((linked_count + 1)); \
			continue; \
		fi; \
		if [ -e "$$dst" ]; then \
			echo "failed $$dst (exists and is not a symlink)"; \
			status=1; failed_count=$$((failed_count + 1)); \
			continue; \
		fi; \
		ln -s "$$src" "$$dst"; \
		echo "linked $$dst -> $$src"; \
		linked_count=$$((linked_count + 1)); \
	done; \
	echo "Managed links: $$ok_count ok, $$linked_count linked, $$failed_count failed."; \
	if [ "$$status" -eq 0 ]; then \
		echo "Managed links succeeded."; \
	else \
		echo "Managed links failed."; \
	fi; \
	exit "$$status"

.PHONY: verify_symlink
verify_symlink:
	@tmp="$$(mktemp -d)"; verify_status=0; \
	trap 'rm -rf "$$tmp"' EXIT INT TERM; \
	mkdir -p "$$tmp/home"; \
	first_log="$$tmp/first.log"; \
	if ! $(MAKE) --no-print-directory _managed_symlink HOME="$$tmp/home" DOTFILES="$(DOTFILES)" > "$$first_log" 2>&1; then \
		echo "failed verify_symlink: first run failed"; \
		cat "$$first_log"; \
		verify_status=1; \
	else \
		linked_count="$$(grep -c '^linked ' "$$first_log" || true)"; \
		if [ "$$linked_count" -eq 7 ]; then \
			echo "ok verify_symlink first run linked 7 managed links"; \
		else \
			echo "failed verify_symlink: expected 7 linked lines, got $$linked_count"; \
			cat "$$first_log"; \
			verify_status=1; \
		fi; \
	fi; \
	second_log="$$tmp/second.log"; \
	if ! $(MAKE) --no-print-directory _managed_symlink HOME="$$tmp/home" DOTFILES="$(DOTFILES)" > "$$second_log" 2>&1; then \
		echo "failed verify_symlink: second run failed"; \
		cat "$$second_log"; \
		verify_status=1; \
	else \
		ok_count="$$(grep -c '^ok ' "$$second_log" || true)"; \
		if [ "$$ok_count" -eq 7 ]; then \
			echo "ok verify_symlink second run reported 7 existing links"; \
		else \
			echo "failed verify_symlink: expected 7 ok lines, got $$ok_count"; \
			cat "$$second_log"; \
			verify_status=1; \
		fi; \
	fi; \
	mkdir -p "$$tmp/conflict-home"; \
	printf 'local config\n' > "$$tmp/conflict-home/.zshrc"; \
	conflict_log="$$tmp/conflict.log"; \
	if $(MAKE) --no-print-directory _managed_symlink HOME="$$tmp/conflict-home" DOTFILES="$(DOTFILES)" > "$$conflict_log" 2>&1; then \
		echo "failed verify_symlink: existing non-symlink destination did not fail"; \
		cat "$$conflict_log"; \
		verify_status=1; \
	else \
		echo "ok verify_symlink existing non-symlink destination failed safely"; \
	fi; \
	missing_log="$$tmp/missing.log"; \
	if $(MAKE) --no-print-directory _managed_symlink HOME="$$tmp/missing-home" DOTFILES="$(DOTFILES)" MANAGED_LINKS="$$tmp/missing-source::$$tmp/missing-home/missing" > "$$missing_log" 2>&1; then \
		echo "failed verify_symlink: missing source did not fail"; \
		cat "$$missing_log"; \
		verify_status=1; \
	else \
		echo "ok verify_symlink missing source failed safely"; \
	fi; \
	if [ "$$verify_status" -eq 0 ]; then \
		echo "verify_symlink succeeded."; \
	else \
		echo "verify_symlink failed."; \
	fi; \
	exit "$$verify_status"

.PHONY: symlink_obsidian_claude
symlink_obsidian_claude:
ifndef OBSIDIAN_CLAUDE
	@echo "ERROR: OBSIDIAN_CLAUDE is not set"
	@echo "Create a Makefile.local file with:"
	@echo "  OBSIDIAN_CLAUDE = /path/to/your/obsidian/claude"
	@exit 1
endif
	@link_dir () { \
		src="$$1"; dst="$$2"; \
		if [ -e "$$dst" ] && [ ! -L "$$dst" ]; then \
			echo "ERROR: $$dst exists and is not a symlink; refusing to create nested symlink"; \
			exit 1; \
		fi; \
		ln -fs "$$src" "$$dst"; \
	}; \
	link_skill_dirs () { \
		src_root="$$1"; dst_root="$$2"; \
		mkdir -p "$$dst_root"; \
		for d in "$$src_root"/*; do \
			[ -d "$$d" ] || continue; \
			name="$${d##*/}"; \
			dst="$$dst_root/$$name"; \
			if [ -e "$$dst" ] && [ ! -L "$$dst" ]; then \
				echo "ERROR: $$dst exists and is not a symlink; refusing to create nested symlink"; \
				exit 1; \
			fi; \
			ln -fs "$$d" "$$dst"; \
		done; \
	}; \
	link_dir "$(OBSIDIAN_CLAUDE)/agents" "${HOME}/.claude/agents"; \
	link_skill_dirs "$(OBSIDIAN_CLAUDE)/skills" "${HOME}/.claude/skills"; \
	link_dir "$(OBSIDIAN_CLAUDE)/marketplaces" "${HOME}/.claude/plugins/marketplaces"; \
	link_dir "$(OBSIDIAN_CLAUDE)/AGENTS.md" "${HOME}/.claude/CLAUDE.md"; \
	link_skill_dirs "$(OBSIDIAN_CLAUDE)/skills" "${HOME}/.agents/skills"; \
	link_dir "$(OBSIDIAN_CLAUDE)/AGENTS.md" "${HOME}/.codex/AGENTS.md"

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
