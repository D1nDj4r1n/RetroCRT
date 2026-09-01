# retrocrt — Powerlevel10k colour overlay
#
# Source this AFTER ~/.p10k.zsh. It does not rewrite your prompt: no segment
# list, no separators, no icons, no layout. It only reassigns colours, so
# `p10k configure` remains usable and your own p10k choices survive.
#
#   [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
#   source ~/.config/zsh/p10k.retrocrt.zsh
#
# p10k takes terminal colour *indices*, not hex, so retrocrt reaches it through
# the Ghostty ANSI mapping. That indirection is the point: fix the terminal
# palette once and every index-only application follows.
#
#   0 BACKGROUND   1 RED     2 GREEN   3 AMBER
#   4 BLUE         5 MAGENTA 6 CYAN    7 FOREGROUND   8 DIM

# --- prompt character: the CRT state language ----------------------------------
# NORMAL cyan, INSERT amber, VISUAL magenta. Same meaning as the Vim,
# Neovim and Yazi mode indicators.
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND=3
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VICMD_FOREGROUND=6
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIVIS_FOREGROUND=5
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIOWR_FOREGROUND=5

# A failed command turns the prompt character red, whatever the mode.
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND=1
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VICMD_FOREGROUND=1
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIVIS_FOREGROUND=1
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIOWR_FOREGROUND=1

# --- location: navigation ------------------------------------------------------
typeset -g POWERLEVEL9K_DIR_FOREGROUND=6
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=8
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=6
typeset -g POWERLEVEL9K_DIR_WRITABLE_FOREGROUND=1

# --- version control: state ----------------------------------------------------
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=2
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=3
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=6
typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=1
typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=8

# --- result and timing ---------------------------------------------------------
typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=2
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=1
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=1
typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=1
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=3
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=6
typeset -g POWERLEVEL9K_TIME_FOREGROUND=8

# --- context -------------------------------------------------------------------
typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND=8
typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=3
typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=1
typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=6

# --- toolchains: informational --------------------------------------------------
typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=4
typeset -g POWERLEVEL9K_PYENV_FOREGROUND=4
typeset -g POWERLEVEL9K_NODEENV_FOREGROUND=4
typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=4

# Apply without restarting the shell.
(( ${+functions[p10k]} )) && p10k reload
