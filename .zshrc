# ------------------------------
# Helpers
# ------------------------------
path_prepend() {
  local dir="$1"
  [ -d "$dir" ] || return 0
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) export PATH="$dir:$PATH" ;;
  esac
}

path_append() {
  local dir="$1"
  [ -d "$dir" ] || return 0
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) export PATH="$PATH:$dir" ;;
  esac
}

# ------------------------------
# Antigen / Oh My Zsh
# ------------------------------
if [ ! -f "$HOME/.antigen.zsh" ]; then
  echo "Downloading and installing Antigen..."
  curl -fsSL https://git.io/antigen -o "$HOME/.antigen.zsh"
fi

source "$HOME/.antigen.zsh"

# Load Oh My Zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo.
antigen bundle git
antigen bundle pip
antigen bundle command-not-found
antigen bundle npm
# antigen bundle docker
antigen bundle docker-compose
antigen bundle safe-paste

# Syntax highlighting and suggestions.
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting

# Tell Antigen that you're done.
antigen apply

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

if command -v aws_completer >/dev/null 2>&1; then
  complete -C "$(command -v aws_completer)" aws
fi

# Colors
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=247'

# Alias (portable)
if command -v colorls >/dev/null 2>&1; then
  alias ls='colorls'
elif ls --color -d . >/dev/null 2>&1; then
  alias ls='ls --color=auto'
elif ls -G -d . >/dev/null 2>&1; then
  alias ls='ls -G'
fi

# Vi mode in Zsh
bindkey -v
precmd() { RPROMPT="" }
function zle-line-init zle-keymap-select {
  VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
  RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $EPS1"
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1

# ------------------------------
# Editors
# ------------------------------
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="$(command -v nvim)"
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="$(command -v vim)"
else
  export EDITOR="vi"
fi
export VISUAL="$EDITOR"

# ------------------------------
# PATH setup (portable)
# ------------------------------
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

# Ruby user gem bin (dynamic)
if command -v ruby >/dev/null 2>&1; then
  ruby_user_bin="$(ruby -r rubygems -e 'print Gem.user_dir' 2>/dev/null)/bin"
  path_prepend "$ruby_user_bin"
fi

# Homebrew Ruby (macOS, dynamic)
if command -v brew >/dev/null 2>&1; then
  brew_prefix="$(brew --prefix 2>/dev/null)"
  path_prepend "$brew_prefix/opt/ruby/bin"
fi

# Starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
path_prepend "$PYENV_ROOT/bin"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi

# Secrets (optional)
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

# pnpm (portable)
if [ -d "$HOME/Library/pnpm" ]; then
  export PNPM_HOME="$HOME/Library/pnpm"
elif [ -d "$HOME/.local/share/pnpm" ]; then
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
[ -n "$PNPM_HOME" ] && path_prepend "$PNPM_HOME"

# LM Studio CLI (optional)
path_append "$HOME/.lmstudio/bin"

# gvm (optional)
[ -s "$HOME/.gvm/scripts/gvm" ] && source "$HOME/.gvm/scripts/gvm"

# Antigravity (optional)
path_prepend "$HOME/.antigravity/antigravity/bin"

# Opencode (optional)
path_prepend "$HOME/.opencode/bin"
