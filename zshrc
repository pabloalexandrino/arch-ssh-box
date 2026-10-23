export PATH="$HOME/.local/bin:$PATH"
export EDITOR=nvim
alias ll='ls -lah --color=auto'
alias v=nvim
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias cc='claude'
alias cx='codex'
# entra no tmux automaticamente em sessões SSH
if [[ -n "$SSH_CONNECTION" && -z "$TMUX" ]]; then exec tmux new-session -A -s main; fi
