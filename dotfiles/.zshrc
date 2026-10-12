# brew (first, so its completions are on fpath before compinit)
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

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

# mise
(( $+commands[mise] )) && eval "$(mise activate zsh)"

# control + g to jump to repo dir
ghq-fzf() {
  local dir=$(ghq list -p | fzf --query="$LBUFFER")
  if [[ -n $dir ]]; then
    BUFFER="cd ${(q)dir}"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N ghq-fzf
bindkey '^g' ghq-fzf

# starship
(( $+commands[starship] )) && eval "$(starship init zsh)"

# direnv
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
