# retrocrt — zsh adapter
# Canonical palette: ../../palette (or ~/.config/retrocrt/palette)
#
# Source this AFTER:
#   plugins -> Oh My Zsh -> Powerlevel10k -> zsh-syntax-highlighting (LAST plugin)
# This file is not a plugin. It only sets colors.
#
# It does not rewrite ~/.p10k.zsh. It only overrides color tokens after p10k loads.
# It does not change bindkey, fonts, or plugin order.

# Load canonical palette if present.
() {
  local f
  for f in \
    "${HOME}/.config/retrocrt/palette" \
    "${${(%):-%N}:A:h:h:h}/palette"
  do
    if [[ -r $f ]]; then
      set -a
      source "$f"
      set +a
      break
    fi
  done
}

: ${BACKGROUND:=#0a0e14}
: ${BACKGROUND_ALT:=#121820}
: ${FOREGROUND:=#c8d0d8}
: ${DIM:=#5a6570}
: ${CYAN:=#00d4c8}
: ${AMBER:=#ffb020}
: ${MAGENTA:=#e040a0}
: ${GREEN:=#40c070}
: ${RED:=#e05050}
: ${BLUE:=#4080c0}

# Suggestions / secondary information
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${DIM}"

# Syntax highlighting. typeset first so this is safe even if sourced
# before the plugin; values still win if sourced after it (required).
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]="fg=${FOREGROUND}"
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=${RED}"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=${CYAN}"
ZSH_HIGHLIGHT_STYLES[alias]="fg=${CYAN}"
ZSH_HIGHLIGHT_STYLES[suffix-alias]="fg=${CYAN}"
ZSH_HIGHLIGHT_STYLES[global-alias]="fg=${CYAN}"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=${CYAN}"
ZSH_HIGHLIGHT_STYLES[function]="fg=${GREEN}"
ZSH_HIGHLIGHT_STYLES[command]="fg=${CYAN}"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=${CYAN}"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=${DIM}"
ZSH_HIGHLIGHT_STYLES[hashed-command]="fg=${CYAN}"
ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=${CYAN}"
ZSH_HIGHLIGHT_STYLES[path]="fg=${CYAN}"
ZSH_HIGHLIGHT_STYLES[path_prefix]="fg=${CYAN}"
ZSH_HIGHLIGHT_STYLES[globbing]="fg=${BLUE}"
ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=${BLUE}"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=${DIM}"
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=${DIM}"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=${AMBER}"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=${AMBER}"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=${AMBER}"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=${AMBER}"
ZSH_HIGHLIGHT_STYLES[assign]="fg=${FOREGROUND}"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=${MAGENTA}"
ZSH_HIGHLIGHT_STYLES[comment]="fg=${DIM}"
ZSH_HIGHLIGHT_STYLES[arg0]="fg=${CYAN}"
ZSH_HIGHLIGHT_STYLES[bracket-error]="fg=${RED}"
ZSH_HIGHLIGHT_STYLES[bracket-level-1]="fg=${CYAN}"
ZSH_HIGHLIGHT_STYLES[bracket-level-2]="fg=${BLUE}"
ZSH_HIGHLIGHT_STYLES[bracket-level-3]="fg=${GREEN}"
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]="fg=${BACKGROUND},bg=${CYAN}"

# Powerlevel10k color overlay (optional, only if p10k is loaded).
# CRT prompt character: NORMAL=CYAN INSERT=AMBER VISUAL=MAGENTA REPLACE=RED
if (( ${+functions[p10k]} )) || [[ -n ${POWERLEVEL9K_PROMPT_CHAR_OK_VICMD_FOREGROUND+x} || -n ${POWERLEVEL9K_MODE+x} ]]; then
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VICMD_FOREGROUND="$CYAN"
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND="$AMBER"
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIVIS_FOREGROUND="$MAGENTA"
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIOWR_FOREGROUND="$RED"
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VICMD_FOREGROUND="$RED"
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND="$RED"
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIVIS_FOREGROUND="$RED"
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIOWR_FOREGROUND="$RED"

  typeset -g POWERLEVEL9K_DIR_FOREGROUND="$CYAN"
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND="$CYAN"
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND="$CYAN"

  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND="$GREEN"
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND="$RED"

  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND="$GREEN"
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND="$AMBER"
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND="$AMBER"
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND="$RED"
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND="$AMBER"
fi
