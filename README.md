# dotfiles

Shell, git, prompt, mise and Claude Code settings, plus the Homebrew and App Store apps to install, for Apple Silicon Macs. Intel Macs, Rosetta shells and Linux aren't supported, and `make` stops early on them.

## Before you start

- An Apple Silicon Mac. Open Terminal normally, not under Rosetta.
- Sign in to the App Store. The last setup step installs App Store apps and fails without an account. Paid apps such as Mp3tag also need to have been bought with that account.
- Your account needs admin rights. The Homebrew installer and the App Store step ask for your password.

## Fresh Mac setup

1. **Install the Xcode Command Line Tools.** They provide `git` and `make`. Follow the dialog that opens:

   ```sh
   xcode-select --install
   ```

2. **Clone this repo.** HTTPS works without an SSH key, and git uses `gh` for GitHub credentials later. The links point into this checkout, so pick its final location now. Cloning under `~/projects/github.com/<owner>/dotfiles` matches the ghq layout that Ctrl+G searches:

   ```sh
   git clone https://github.com/<owner>/dotfiles.git ~/projects/github.com/<owner>/dotfiles
   cd ~/projects/github.com/<owner>/dotfiles
   ```

3. **Run the installer** from the checkout:

   ```sh
   make install
   ```

   It runs these steps in order and stops at the first one that fails:

   | Step | What it does |
   | --- | --- |
   | `check_arch` | Stops unless the Mac is Apple Silicon and the shell isn't under Rosetta. |
   | `symlink` | Links the dotfiles into `~` (see [What gets linked](#what-gets-linked)). |
   | `install_brew` | Installs Homebrew to `/opt/homebrew` if it isn't there. |
   | `install_brew_packages` | Installs the formulae and casks in `dotfiles/Brewfile`. |
   | `install_mise_tools` | Runs `mise install` for the tools in `dotfiles/mise/config.toml` (node, bun). |
   | `install_mas_apps` | Installs the App Store apps in `dotfiles/Brewfile.mas`, including Xcode, which is a large download. |

   If only the App Store step fails, fix the cause (usually by signing in) and run `make install_mas_apps`. It re-runs the earlier steps first, which is quick because they're already done.

4. **Open a new terminal** so `.zshrc` loads Homebrew, mise, starship and the zi plugins. The first shell clones zi into `~/.zi`.

5. **Sign in to GitHub.** Git uses `gh` as its credential helper for github.com:

   ```sh
   gh auth login
   ```

6. **Download the iOS simulator runtime** once Xcode has installed. Xcode from the App Store includes the Simulator app but not the iOS runtime. Switch the active developer directory from the Command Line Tools to Xcode, finish Xcode's first-launch setup, then download the runtime:

   ```sh
   sudo xcode-select -s /Applications/Xcode.app
   sudo xcodebuild -runFirstLaunch
   xcodebuild -downloadPlatform iOS
   ```

### Optional

- **SSH commit signing.** Copy the example, set `signingkey` to your public key, and add that key to GitHub as a signing key:

  ```sh
  cp dotfiles/.gitconfig.local.example ~/.config/git/config.local
  ```

- **Agent skills from Obsidian.** Once Obsidian is installed and the vault has synced, point `OBSIDIAN_CLAUDE` at the vault's Claude folder. Either copy `Makefile.local.example` to `Makefile.local`, set it there, and run:

  ```sh
  make symlink_agents
  ```

  Or pass it on the command line:

  ```sh
  make symlink_agents OBSIDIAN_CLAUDE=<path>
  ```

  This links each folder in `skills/` into `~/.claude/skills` and `~/.agents/skills`, and links `AGENTS.md` to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`.

## Existing Mac

Running `make install` again is safe. Links that already point into this checkout are left alone. The Homebrew and App Store steps install what's missing and upgrade outdated packages from the Brewfiles, and mise installs any missing tool versions.

If a file or folder is already at a link destination, `symlink` and `symlink_agents` move it to `~/.dotfiles-backup/<timestamp>-<pid>/`, keeping its path relative to `~`, and then link. Copy anything you want to keep from there into this repo or into the local files below. If a move or link fails, the run stops with an error that says where the original is: still at the destination, or in the backup folder if it couldn't be moved back.

After pulling changes, open a new terminal for shell changes, and run `make install_brew_packages` or `make install_mise_tools` for new packages or tools.

## Make targets

Each target runs the targets it depends on first, so `make install_mise_tools` also links the dotfiles and runs the Brewfile.

| Target | Runs |
| --- | --- |
| `make install` | Everything in step 3 of [Fresh Mac setup](#fresh-mac-setup). |
| `make symlink` | Links the dotfiles. |
| `make symlink_agents` | Links agent skills and `AGENTS.md` from the Obsidian vault. Needs `OBSIDIAN_CLAUDE`. |
| `make install_brew` | Installs Homebrew. |
| `make install_brew_packages` | Installs `dotfiles/Brewfile`. |
| `make install_mise_tools` | Installs the mise tools. |
| `make install_mas_apps` | Installs `dotfiles/Brewfile.mas`. |

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

Machine-specific settings stay out of the repo, in `~/.config/git/config.local` and `Makefile.local`. Both are read if present and ignored otherwise.
