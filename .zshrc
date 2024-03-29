# if antigen is not installed, download it.
if [ ! -f ~/.antigen.zsh ]; then
	echo "Downloading and installing Antigen..."
	curl -L git.io/antigen > .antigen.zsh
fi

source ~/.antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle pip
antigen bundle command-not-found
antigen bundle npm
antigen bundle docker
antigen bundle docker-compose
antigen bundle safe-paste

# Syntax highlighting and suggestions bundle.
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting

# Load the theme.
# antigen theme bhilburn/powerlevel9k powerlevel9k

# Tell Antigen that you're done.
antigen apply

# Colors
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=247'

# Alias
alias open='mimeo'
alias zshconfig="nvim ~/.zshrc"
alias vimconfig="nvim ~/.vim/vimrc"
alias reload="source ~/.zshrc"
alias lc="colorls"

# Vi Mode in ZSH
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

# Node Version Manager Lazy Loading
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# This lazy loads nvm
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use # This loads nvm
  nvm $@
}

# This resolves the default node version
DEFAULT_NODE_VER="$( (< "$NVM_DIR/alias/default" || < ~/.nvmrc) 2> /dev/null)"
while [ -s "$NVM_DIR/alias/$DEFAULT_NODE_VER" ] && [ ! -z "$DEFAULT_NODE_VER" ]; do
  DEFAULT_NODE_VER="$(<"$NVM_DIR/alias/$DEFAULT_NODE_VER")"
done

# This adds the default node version to PATH
if [ ! -z "$DEFAULT_NODE_VER" ]; then
  export PATH="$NVM_DIR/versions/node/v${DEFAULT_NODE_VER#v}/bin:$PATH"
fi

# Default editor
export EDITOR="/usr/bin/nvim"

# powerlevel9k
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir virtualenv vcs)

# ruby
export PATH=$PATH:/home/gabriel/.local/share/gem/ruby/3.0.0/bin

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# startship
eval "$(starship init zsh)"

