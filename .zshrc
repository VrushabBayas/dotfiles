### >>> POWERLEVEL10K INSTANT PROMPT (must be at the very top) <<<
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
### >>> END OF INSTANT PROMPT <<<

# -------------------------------------------
# Basic Environment
# -------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export TERM="xterm-256color"

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# PATH Configuration (order matters - most specific first)
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.volta/bin:$PATH"
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

# Tmux with XDG config
alias tmux="tmux -f $XDG_CONFIG_HOME/tmux/tmux.conf"

# -------------------------------------------
# Theme: Powerlevel10k
# -------------------------------------------
ZSH_THEME="powerlevel10k/powerlevel10k"

# -------------------------------------------
# Plugins
# -------------------------------------------
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  sudo
  tmux
  fzf
  # z plugin removed - using zoxide instead
  common-aliases
  colored-man-pages
)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Source p10k config after oh-my-zsh
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# -------------------------------------------
# History Settings (set early)
# -------------------------------------------
HISTSIZE=10000
SAVEHIST=20000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY

# -------------------------------------------
# Completion Setup
# -------------------------------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# -------------------------------------------
# Colors
# -------------------------------------------
autoload -U colors && colors
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# -------------------------------------------
# Tool Shortcuts
# -------------------------------------------
alias lg="lazygit"
alias y="yazi"
alias fd="fd -H"                          # include hidden files
alias fda="fd --no-ignore --hidden"       # include .gitignored too
alias z="z" # zoxide command (modern 'z' for directory navigation)
alias ls='eza --icons --ignore-glob=node_modules'
alias l='eza -lah --icons --ignore-glob=node_modules'
alias lt='eza --tree --icons --ignore-glob=node_modules'
alias ..="cd .."
alias ...="cd ../.."
alias config="nvim ~/.zshrc"
alias reload="source ~/.zshrc"

# -------------------------------------------
# Directory Navigation
# -------------------------------------------
alias personal='cd ~/personal'
alias work='cd ~/work'

# ----------------------------
# FZF Configuration
# ----------------------------
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git --exclude node_modules'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_COMPLETION_TRIGGER='**'

export FZF_DEFAULT_OPTS='
  --bind=up:up
  --bind=down:down
  --bind=left:backward-char
  --bind=right:forward-char
  --height=40% 
  --layout=reverse 
  --info=inline
  --preview-window=right:60%:wrap
  --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
  --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
  --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
  --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# Initialize FZF
eval "$(fzf --zsh)"

# FZF Git integration (check if file exists)
[[ -f ~/fzf-git.sh/fzf-git.sh ]] && source ~/fzf-git.sh/fzf-git.sh

# -------------------------------------------
# Custom Functions
# -------------------------------------------

# Fuzzy open file with preview
fo() {
  local file
  file=$(fd . --type f --hidden --exclude .git --exclude node_modules \
    | fzf \
        --height=100% \
        --preview 'bat --style=numbers --color=always --line-range :500 {}' \
        --preview-window=right:70%:wrap \
        --bind 'ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down'
  ) && [[ -n "$file" ]] && nvim "$file"
}

# Fuzzy Git branch checkout
fco() {
  local branch
  branch=$(git branch --all | grep -v HEAD | sed 's/.* //' | sed 's/remotes\///' | sort -u | fzf)
  [[ -n "$branch" ]] && git checkout "$branch"
}

# Fuzzy kill process
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf --multi --preview 'echo {}' | awk '{print $2}')
  [[ -n "$pid" ]] && echo "$pid" | xargs kill -9
}

# Fuzzy open recent zoxide directory
fj() {
  command -v zoxide >/dev/null 2>&1 || { echo "zoxide not installed"; return 1; }
  local dir
  dir=$(zoxide query -l | fzf --preview 'eza -1 --color=always {}')
  [[ -n "$dir" ]] && cd "$dir"
}

# -------------------------------------------
# Tmux Functions and Aliases
# -------------------------------------------

# Session picker with fzf (renamed to avoid conflict with ts alias)
tsel() {
  command -v tmux >/dev/null 2>&1 || { echo "tmux not installed"; return 1; }
  local session
  session=$(tmux list-sessions -F "#S" 2>/dev/null | fzf --prompt="Select tmux session: ")
  [[ -n "$session" ]] && tmux attach -t "$session"
}

# Kill all tmux sessions
tkall() {
  command -v tmux >/dev/null 2>&1 || { echo "tmux not installed"; return 1; }
  tmux list-sessions -F "#S" 2>/dev/null | xargs -I {} tmux kill-session -t {}
}

# Base tmux commands
alias ta="tmux attach -t"       # Attach to existing session
alias tn="tmux new -s"          # New session
alias tl="tmux list-sessions"   # List sessions
alias tk="tmux kill-session -t" # Kill session
alias ts='tmux-sessionizer'     # Tmux sessionizer

# Window and pane management
alias tns="tmux new-session -s"   # New session (explicit)
alias tw="tmux new-window -n"     # New window
alias tp="tmux split-window -h"   # Split pane horizontally
alias tv="tmux split-window -v"   # Split pane vertically
alias tmuxr="tmux source-file ~/.config/tmux/tmux.conf"  # Reload config

# Attach to tmux session via fzf
alias tat='tmux list-sessions -F "#S" 2>/dev/null | fzf --prompt="Attach to session: " | xargs -r tmux attach -t'

# Tmux resurrect (if plugin exists)
alias trs="tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/save.sh"
alias trr="tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh"

# -------------------------------------------
# Git Aliases
# -------------------------------------------
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gb='git branch'
alias gcb='git checkout -b'
alias gpull='git pull origin "$(git rev-parse --abbrev-ref HEAD)"'
alias gpush='git push origin "$(git rev-parse --abbrev-ref HEAD)"'
alias gcl='git clone'
alias gr='git remote -v'
alias gd='git diff'
alias gds='git diff --staged'
alias gst='git stash'
alias gstp='git stash pop'
alias gsl='git stash list'
alias gsa='git stash apply'
alias gssh='git stash show'
alias gclean='git clean -fd'
alias gprune='git remote prune origin'
alias gt='git tag'
alias gta='git tag -a'
alias gl='git log --oneline --graph --decorate'
alias glp='git log --oneline --graph --decorate --parents'
alias gla='git log --oneline --graph --decorate --parents --all'
alias gshort='git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'
alias grb='git rebase'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias grsi='git rebase -i'
alias grs='git reset'
alias grsh='git reset --hard'

# -------------------------------------------
# Additional Utility Aliases
# -------------------------------------------
alias f='fd --hidden --exclude .git --exclude node_modules'
# Note: 'z' function is defined above in zoxide section
alias j='z'                   # Alternative to z command

# -------------------------------------------
# Optional: Auto-start tmux (commented out for safety)
# -------------------------------------------
# Uncomment the following lines if you want to auto-start tmux
# if command -v tmux &> /dev/null && [ -z "$TMUX" ] && [ -z "$SSH_CONNECTION" ]; then
#   exec tmux new-session -A -s main
# fi

# -------------------------------------------
# Load local customizations (if exists)
# -------------------------------------------
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
