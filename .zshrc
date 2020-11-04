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
antigen bundle zsh-users/zsh-autosuggestions

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Load the theme.
antigen theme romkatv/powerlevel10k

# Tell Antigen that you're done.
antigen apply

# Alias
alias open='xdg-open'
alias zshconfig="vim ~/.zshrc"
alias vimconfig="vim ~/.vim/vimrc"
alias reload="source ~/.zshrc"

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

# Environment variables
export GOPATH="$HOME/Source/go"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"
export EDITOR="/usr/bin/nvim"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

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

