# dotfiles

Shell, git, prompt, mise and Claude Code settings, plus a Brewfile, for Apple Silicon Macs. Intel Macs, Rosetta shells and Linux aren't supported, and `make` stops early on them.

## Setup

1. Install the Xcode Command Line Tools, which provide `git` and `make`:

   ```sh
   xcode-select --install
   ```

2. Sign in to the App Store, so the Brewfile can install App Store apps. Then clone this repo and run the installer from it:

   ```sh
   make install
   ```

   This links the dotfiles into `~`, installs Homebrew if it's missing, installs everything in `dotfiles/Brewfile`, and installs the mise tools (node, bun). Anything already at a link destination is moved to `~/.dotfiles-backup/<timestamp>-<pid>/` first, and the run stops if a move or link fails. Re-running it is safe.

3. Open a new terminal, then sign in to GitHub. Git uses `gh` for GitHub credentials:

   ```sh
   gh auth login
   ```

4. Optional: turn on SSH commit signing by copying the example and setting your key path:

   ```sh
   cp dotfiles/.gitconfig.local.example ~/.config/git/config.local
   ```

5. Optional: link shared agent skills and `AGENTS.md` from an Obsidian vault once it has synced. Copy `Makefile.local.example` to `Makefile.local`, set `OBSIDIAN_CLAUDE`, then run:

   ```sh
   make symlink_agents
   ```

## What gets linked

| Repo file | Linked to |
| --- | --- |
| `dotfiles/.zshrc` | `~/.zshrc` |
| `dotfiles/.gitconfig` | `~/.config/git/config` |
| `dotfiles/.gitignore` | `~/.config/git/ignore` |
| `dotfiles/.gitmessage.txt` | `~/.config/git/message` |
| `dotfiles/starship.toml` | `~/.config/starship.toml` |
| `dotfiles/mise/config.toml` | `~/.config/mise/config.toml` |
| `dotfiles/.claude/settings.json` | `~/.claude/settings.json` |

Machine-specific settings stay out of the repo, in `~/.config/git/config.local` and `Makefile.local`.
