if [[ ! -f $HOME/.zi/bin/zi.zsh ]]; then
  print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
  command mkdir -p "$HOME/.zi" && command chmod go-rwX "$HOME/.zi"
  command git clone -q --depth=1 --branch "main" https://github.com/z-shell/zi "$HOME/.zi/bin" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi
source "$HOME/.zi/bin/zi.zsh"
autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi

# compinit
zicompinit

# suggestions
zi light "zsh-users/zsh-autosuggestions"

# nvm
export NVM_COMPLETION=true
export NVM_AUTO_USE=true
zi light "lukechilds/zsh-nvm"

# control + g to jump to repo dir
zi light migutw42/zsh-fzf-ghq

# starship
eval "$(starship init zsh)"

# direnv
eval "$(direnv hook zsh)"
