# Powerlevel10k instant prompt must remain near the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export EDITOR=vim
export VISUAL=vim
export GIT_EDITOR=vim
alias ide=nvim

bindkey -v
export KEYTIMEOUT=1

typeset -g RETROCRT_PALETTE="${XDG_CONFIG_HOME:-$HOME/.config}/retrocrt/palette"
if [[ -r "$RETROCRT_PALETTE" ]]; then
  source "$RETROCRT_PALETTE"
else
  print -u2 "retrocrt: palette not found: $RETROCRT_PALETTE"
fi

export CLICOLOR=1
export LS_COLORS="di=1;38;2;0;212;200:ln=38;2;64;128;192:ex=38;2;64;192;112:or=1;38;2;224;80;80:mi=1;38;2;224;80;80:pi=38;2;90;101;112:so=38;2;90;101;112:bd=38;2;90;101;112:cd=38;2;90;101;112"
export GREP_COLORS="ms=38;2;255;176;32:mc=38;2;255;176;32:fn=38;2;64;128;192:ln=38;2;90;101;112:se=38;2;90;101;112"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Configure plugin colors before loading them.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${DIM:-#5a6570}"
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]="fg=${FOREGROUND:-#c8d0d8}"
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=${RED:-#e05050},bold"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=${CYAN:-#00d4c8}"
ZSH_HIGHLIGHT_STYLES[suffix-alias]="fg=${CYAN:-#00d4c8}"
ZSH_HIGHLIGHT_STYLES[global-alias]="fg=${CYAN:-#00d4c8}"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=${CYAN:-#00d4c8}"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=${DIM:-#5a6570}"
ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=${CYAN:-#00d4c8},bold"
ZSH_HIGHLIGHT_STYLES[path]="fg=${BLUE:-#4080c0}"
ZSH_HIGHLIGHT_STYLES[path_prefix]="fg=${DIM:-#5a6570}"
ZSH_HIGHLIGHT_STYLES[command]="fg=${CYAN:-#00d4c8}"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=${CYAN:-#00d4c8}"
ZSH_HIGHLIGHT_STYLES[function]="fg=${GREEN:-#40c070}"
ZSH_HIGHLIGHT_STYLES[hashed-command]="fg=${CYAN:-#00d4c8}"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=${AMBER:-#ffb020}"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=${AMBER:-#ffb020}"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=${AMBER:-#ffb020}"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=${BLUE:-#4080c0}"
ZSH_HIGHLIGHT_STYLES[comment]="fg=${DIM:-#5a6570}"
ZSH_HIGHLIGHT_STYLES[globbing]="fg=${MAGENTA:-#e040a0}"
ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=${MAGENTA:-#e040a0}"

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  zsh-autosuggestions
)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# Keep zsh-syntax-highlighting last: no interactive setup belongs below this.
[[ -r "$ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] &&
  source "$ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
