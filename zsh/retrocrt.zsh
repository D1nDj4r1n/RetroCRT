# retrocrt — zsh adapter
#
# Source this AFTER Oh My Zsh, because zsh-syntax-highlighting installs its
# default styles when it is loaded and the array below has to win. Loading it
# earlier silently gives you the stock highlighting.
#
#   source $ZSH/oh-my-zsh.sh      # syntax-highlighting is the last plugin
#   source ~/.config/zsh/retrocrt.zsh
#
# This file only sets colours and the vi-mode cursor. It defines no aliases,
# changes no keybindings and loads no plugins.

# --- autosuggestions -----------------------------------------------------------
# A suggestion is secondary information, so it recedes to DIM.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#5a6570'

# --- syntax highlighting -------------------------------------------------------
# Restrained on purpose: a command line is not a syntax-highlighted document.
# Only four things are worth colouring while typing — is the command real
# (green), is it broken (red), is it a string (amber), is it shell structure
# (cyan). Everything else stays FOREGROUND.
typeset -gA ZSH_HIGHLIGHT_STYLES

# valid commands: success
ZSH_HIGHLIGHT_STYLES[command]='fg=#40c070'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#40c070'
ZSH_HIGHLIGHT_STYLES[function]='fg=#40c070'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#40c070'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#40c070'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#40c070'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#40c070'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#40c070'

# unknown command: error
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#e05050'

# shell structure: active/technical
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#00d4c8'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#00d4c8'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#00d4c8'

# quoted text: same amber as String in the editors
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#ffb020'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#ffb020'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#ffb020'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#ffb020'

# expansions and globs: informational
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#4080c0'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#4080c0'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#4080c0'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#4080c0'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#4080c0'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#4080c0'

# command substitution is a nested command: special
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#e040a0'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#e040a0'

# plain text and metadata
ZSH_HIGHLIGHT_STYLES[default]='fg=#c8d0d8'
ZSH_HIGHLIGHT_STYLES[path]='fg=#c8d0d8'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#c8d0d8'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#5a6570'

# --- ls colours ----------------------------------------------------------------
# The same four filesystem roles used by netrw, oil.nvim and Yazi:
# directory cyan, executable green, symlink magenta, broken red.
# Deliberately short: no colour per file extension.
#
# LS_COLORS speaks decimal RGB, so the palette appears here as 38;2;R;G;B.
# `retrocrt-check` decodes these triples and checks them like any other colour.
export LS_COLORS='di=38;2;0;212;200:ln=38;2;224;64;160:or=38;2;224;80;80:mi=38;2;224;80;80:ex=38;2;64;192;112:fi=38;2;200;208;216:pi=38;2;224;64;160:so=38;2;224;64;160:bd=38;2;64;128;192:cd=38;2;64;128;192:su=38;2;224;80;80:sg=38;2;224;80;80:tw=38;2;0;212;200:ow=38;2;0;212;200:st=38;2;0;212;200'

# --- completion menu -----------------------------------------------------------
# Set after LS_COLORS, because list-colors is expanded here and now.
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{#5a6570}%d%f'
zstyle ':completion:*:warnings' format '%F{#ffb020}no matches%f'
zstyle ':completion:*:errors' format '%F{#e05050}%d%f'

# --- vi mode cursor -------------------------------------------------------------
# The CRT state language in the shell: NORMAL cyan block, INSERT amber bar,
# VISUAL magenta block. Requires `bindkey -v`; harmless without it.
#
# OSC 12 sets the cursor colour, CSI q sets its shape. Ghostty, and most other
# terminals, understand both.
retrocrt_cursor() {
  case "$1" in
    normal)  printf '\e[2 q\e]12;#00d4c8\a' ;;  # steady block, cyan
    insert)  printf '\e[6 q\e]12;#ffb020\a' ;;  # steady bar, amber
    visual)  printf '\e[2 q\e]12;#e040a0\a' ;;  # steady block, magenta
  esac
}

retrocrt_zle_keymap_select() {
  case "$KEYMAP" in
    vicmd)         retrocrt_cursor normal ;;
    visual|vivis)  retrocrt_cursor visual ;;
    *)             retrocrt_cursor insert ;;
  esac
}

retrocrt_zle_line_init() {
  retrocrt_cursor insert
}

# Leave the cursor in a sane state for whatever runs next.
retrocrt_zle_line_finish() {
  retrocrt_cursor insert
}

zle -N retrocrt_zle_keymap_select
zle -N retrocrt_zle_line_init
zle -N retrocrt_zle_line_finish

# add-zle-hook-widget appends to a hook instead of replacing it. Defining
# zle-keymap-select and friends directly would clobber the hooks that
# Powerlevel10k and zsh-syntax-highlighting install, so that path is a last
# resort for zsh older than 5.3.
#
# The first call is the availability test: plain `autoload` cannot tell us
# whether the function file exists, but running it can.
autoload -Uz add-zle-hook-widget 2>/dev/null
if add-zle-hook-widget keymap-select retrocrt_zle_keymap_select 2>/dev/null; then
  add-zle-hook-widget line-init   retrocrt_zle_line_init
  add-zle-hook-widget line-finish retrocrt_zle_line_finish
else
  print -u2 'retrocrt: add-zle-hook-widget unavailable, installing zle widgets directly'
  zle -N zle-keymap-select retrocrt_zle_keymap_select
  zle -N zle-line-init     retrocrt_zle_line_init
  zle -N zle-line-finish   retrocrt_zle_line_finish
fi

# --- less ------------------------------------------------------------------------
# man pages, git log and anything else piped through less. Only the four roles
# less actually has, mapped with ANSI indices so they follow the Ghostty palette.
export LESS="${LESS:--R}"
export LESS_TERMCAP_md=$'\e[1;36m'   # bold / headings   -> cyan
export LESS_TERMCAP_us=$'\e[4;33m'   # underline         -> amber
export LESS_TERMCAP_so=$'\e[1;30;46m' # status line      -> cyan surface
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
