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
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
export XDG_CONFIG_HOME="$HOME/.config"
alias tmux="tmux -f $XDG_CONFIG_HOME/tmux/tmux.conf"

# -------------------------------------------
# Theme: Powerlevel10k
# -------------------------------------------
ZSH_THEME="powerlevel10k/powerlevel10k"
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

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
  z             # smart directory jumping
  common-aliases
  colored-man-pages
)
source $ZSH/oh-my-zsh.sh

# -------------------------------------------
# Tool Shortcuts
# -------------------------------------------
alias lg="lazygit"
alias y="yazi"
alias fd="fd -H"                          # include hidden files
alias fda="fd --no-ignore --hidden"       # include .gitignored too
alias z="z"                              # shortcut for jumping via `z`
alias ls='eza --icons'
alias l='eza -lah --icons'
alias ..="cd .."
alias ...="cd ../.."
alias config="nvim ~/.zshrc"
alias reload="source ~/.zshrc"

# ----------------------------
# FZF + fd + zoxide Professional Setup
# ----------------------------

# --- FZF Config ---
# Use fd instead of find
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_COMPLETION_TRIGGER='**'

# Keybindings (Ctrl+T, Ctrl+R, Alt+C)
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# --- zoxide (modern 'z') ---
eval "$(zoxide init zsh)"
alias j='zi'       # Fuzzy jump to recent dirs

# --- Utility Functions ---

# Fuzzy open file with preview
fo() {
  local file
  file=$(fzf --preview 'bat --style=numbers --color=always --line-range :500 {}') && nvim "$file"
}

# Fuzzy Git branch checkout
fco() {
  git checkout "$(git branch --all | grep -v HEAD | sed 's/.* //' | fzf)"
}

# Fuzzy kill process
fkill() {
  ps -ef | sed 1d | fzf --multi | awk '{print $2}' | xargs kill -9
}

# Optional: Fuzzy open recent zoxide directory
fj() {
  local dir
  dir=$(zoxide query -l | fzf --preview 'eza -1 --color=always {}') && z "$dir"
}

# --- Optional: fd alias for quicker searching ---
alias f='fd --hidden --exclude .git'

eval "$(fzf --zsh)"

# FZF Git integration (adjust path if needed)
source ~/fzf-git.sh/fzf-git.sh

# Custom directories
alias personal='cd ~/personal'
alias work='cd ~/work'
alias ts='tmux-sessionizer'

# -------------------------------------------
# Git Helpers
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
alias grs='git reset'
alias grsh='git reset --hard'

# History Settings
HISTSIZE=10000
SAVEHIST=20000
HISTFILE=~/.zsh_history

# -------------------------------------------
# LS Colors
# -------------------------------------------
autoload -U colors && colors
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# -------------------------------------------
# Completion Tweaks
# -------------------------------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# -------------------------------------------
# Starship (optional replacement for p10k)
# -------------------------------------------
# eval "$(starship init zsh)"

# ----- Base commands -----
alias ta="tmux attach -t"       # Attach to existing session
alias tn="tmux new -s"          # New session
alias tl="tmux list-sessions"   # List sessions
alias tk="tmux kill-session -t" # Kill session

# ----- Window and pane management -----
alias tns="tmux new-session -s"   # New session (explicit)
alias tw="tmux new-window -n"     # New window
alias tp="tmux split-window -h"   # Split pane horizontally
alias tv="tmux split-window -v"   # Split pane vertically
alias tmuxr="tmux source-file ~/.config/tmux/.tmux.conf"  # Reload config

#if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
#  exec tmux
#fi

# ----- Session picker (fzf required) -----
#ts() {
#  local session
#  session=$(tmux list-sessions -F "#S" | fzf) && tmux attach -t "$session"
#}

# ----- Kill all tmux sessions -----
tkall() {
  tmux list-sessions -F "#S" | xargs -I {} tmux kill-session -t {}
}

# Attach to tmux session via fzf (safer, interactive)
alias tat='tmux list-sessions -F "#S" | fzf --prompt="Attach to session: " | xargs -r tmux attach -t'

# ----- Save + Restore Layout (requires tmux-resurrect plugin) -----
alias trs="tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/save.sh"
alias trr="tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh"


