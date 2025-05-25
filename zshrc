# ZSH Configuration for Claude Code Docker Environment

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY

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

# Aliases
alias ls='eza --color=auto --icons'
alias ll='eza -la --color=auto --icons'
alias la='eza -a --color=auto --icons'
alias l='eza -l --color=auto --icons'
alias tree='eza --tree --color=auto --icons'

alias cat='bat'
alias find='fd'
alias grep='rg'
alias vim='nvim'
alias vi='nvim'

alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'
alias gd='git diff'
alias lg='lazygit'

alias dc='docker-compose'
alias dps='docker ps'
alias dpa='docker ps -a'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Load plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fpath=(~/.zsh/zsh-completions/src $fpath)

# FZF integration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Zoxide integration
eval "$(zoxide init zsh)"

# Git delta integration
export GIT_PAGER='delta'

# Claude Code specific
alias cc='claude'
alias ccc='claude code'

# Welcome message
echo "🚀 Claude Code Docker Environment Ready!"
echo "Type 'claude login' if you haven't authenticated yet."