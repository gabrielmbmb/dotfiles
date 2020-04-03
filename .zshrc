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
nvm() {
    unset -f nvm
    export NVM_DIR=~/.nvm
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
    nvm "$@"
}

node() {
    unset -f node
    export NVM_DIR=~/.nvm
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
    node "$@"
}

npm() {
    unset -f npm
    export NVM_DIR=~/.nvm
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
    npm "$@"
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# added by travis gem
[ -f /home/gmdev/.travis/travis.sh ] && source /home/gmdev/.travis/travis.sh

# Environment variables
export GOPATH="$HOME/Source/go"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"
export EDITOR="/usr/bin/vim"
