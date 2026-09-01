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

function retrocrt_sgr() {
  local hex="${1#\#}"
  printf '38;2;%d;%d;%d' \
    "$(( 16#${hex[1,2]} ))" \
    "$(( 16#${hex[3,4]} ))" \
    "$(( 16#${hex[5,6]} ))"
}

export CLICOLOR=1
export LS_COLORS="di=1;$(retrocrt_sgr "$CYAN"):ln=$(retrocrt_sgr "$BLUE"):ex=$(retrocrt_sgr "$GREEN"):or=1;$(retrocrt_sgr "$RED"):mi=1;$(retrocrt_sgr "$RED"):pi=$(retrocrt_sgr "$DIM"):so=$(retrocrt_sgr "$DIM"):bd=$(retrocrt_sgr "$DIM"):cd=$(retrocrt_sgr "$DIM")"
export GREP_COLORS="ms=$(retrocrt_sgr "$AMBER"):mc=$(retrocrt_sgr "$AMBER"):fn=$(retrocrt_sgr "$BLUE"):ln=$(retrocrt_sgr "$DIM"):se=$(retrocrt_sgr "$DIM")"
unfunction retrocrt_sgr
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
