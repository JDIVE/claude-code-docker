# ZSH Configuration for Claude Code Docker Environment

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_IGNORE_SPACE      # Don't record commands that start with space
setopt HIST_IGNORE_DUPS       # Don't record duplicated commands
setopt HIST_FIND_NO_DUPS      # Don't show duplicates when searching

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

# Key bindings
bindkey -e  # Emacs mode
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '(%b)'
setopt PROMPT_SUBST
PROMPT='%F{blue}%n@%m%f:%F{green}%~%f%F{yellow}${vcs_info_msg_0_}%f %# '

# Environment variables
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export LESS='-R'
export PATH="$HOME/.local/bin:$PATH"

# FZF configuration
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always {}'"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Navigation aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"

# List files (using eza)
alias ls="eza --color=auto"
alias ll="eza -la --git --icons"
alias la="eza -a --icons"
alias l="eza -l --git --icons"
alias lt="eza -T --icons --git-ignore"
alias lta="eza -Ta --icons"
alias lg="eza -l --git --icons --git-ignore"

# Git shortcuts
alias g="git"
alias gs="git status -sb"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit"
alias gcm="git commit -m"
alias gca="git commit --amend"
alias gp="git push"
alias gpf="git push --force-with-lease"
alias gl="git pull"
alias gf="git fetch --all --prune"
alias gd="git diff"
alias gds="git diff --staged"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gb="git branch"
alias gba="git branch -a"
alias gbd="git branch -d"
alias gbD="git branch -D"
alias glog="git log --oneline --decorate --graph"
alias gloga="git log --oneline --decorate --graph --all"
alias grb="git rebase"
alias gst="git stash"
alias gstp="git stash pop"
alias gsts="git stash show --text"

# Use lazygit if available
if command -v lazygit &> /dev/null; then
  alias lg="lazygit"
fi

# System shortcuts
alias zshrc="$EDITOR ~/.zshrc"
alias reload="source ~/.zshrc"
alias path="echo $PATH | tr ':' '\n'"
alias c="clear"

# Docker shortcuts
alias dc="docker-compose"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dimg="docker images"
alias drmi="docker rmi"
alias drmif="docker rmi -f"
alias dstop="docker stop"
alias drm="docker rm"
alias dexec="docker exec -it"
alias dlogs="docker logs -f"

# Enhanced tools aliases
alias cat="bat --paging=never"
alias preview="bat --color=always"
alias du="ncdu --color dark -rr -x"
alias help="tldr"
alias http="httpie"
alias find="fd"
alias vim="nvim"
alias vi="nvim"

# Claude Code specific
alias cc='claude'
alias ccc='claude code'

# Utility functions
# Create a new directory and enter it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract most know archives with one command
extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Weather in terminal
weather() {
  curl -s "wttr.in/$1?m1"
}

# Load plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fpath=(~/.zsh/zsh-completions/src $fpath)

# Initialize zoxide (better cd command)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# Git delta integration
export GIT_PAGER='delta'

# Welcome message
echo "🚀 Claude Code Docker Environment Ready!"
echo "Type 'claude login' if you haven't authenticated yet."