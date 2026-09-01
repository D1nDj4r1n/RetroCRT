#!/bin/sh
# retrocrt — verify palette consistency and that adapters load.

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$ROOT"

fail=0
ok() { printf 'OK    %s\n' "$1"; }
bad() { printf 'FAIL  %s\n' "$1"; fail=1; }

# shellcheck disable=SC1091
. "$ROOT/palette"

CANON="$BACKGROUND $BACKGROUND_ALT $FOREGROUND $DIM $CYAN $AMBER $MAGENTA $GREEN $RED $BLUE"
DERIVED="$VISUAL_BG $DIFF_ADD_BG $DIFF_DELETE_BG $DIFF_CHANGE_BG"

need_hex() {
  file=$1
  shift
  for hex in "$@"; do
    if ! grep -Fq "$hex" "$file"; then
      bad "$file missing $hex"
      return 1
    fi
  done
  return 0
}

echo "=== palette ==="
for var in BACKGROUND BACKGROUND_ALT FOREGROUND DIM CYAN AMBER MAGENTA GREEN RED BLUE \
           VISUAL_BG DIFF_ADD_BG DIFF_DELETE_BG DIFF_CHANGE_BG \
           BRIGHT_RED BRIGHT_GREEN BRIGHT_YELLOW BRIGHT_BLUE BRIGHT_MAGENTA BRIGHT_CYAN BRIGHT_WHITE; do
  eval "val=\$$var"
  case "$val" in
    \#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]) ok "$var=$val" ;;
    *) bad "$var unset or not #RRGGBB ($val)" ;;
  esac
done

[ "$BACKGROUND" = "#0a0e14" ] && ok "BACKGROUND canonical" || bad "BACKGROUND drifted"
[ "$CYAN" = "#00d4c8" ] && ok "CYAN canonical" || bad "CYAN drifted"
[ "$AMBER" = "#ffb020" ] && ok "AMBER canonical" || bad "AMBER drifted"
[ "$BRIGHT_BLACK" = "$DIM" ] && ok "bright-black is DIM" || bad "bright-black is not DIM"
[ "$ANSI_YELLOW" = "$AMBER" ] && ok "ANSI yellow is AMBER" || bad "ANSI yellow drifted"
[ "$ANSI_BLACK" = "$BACKGROUND" ] && ok "ANSI black is BACKGROUND" || bad "ANSI black drifted"

echo
echo "=== adapters contain canonical HEX ==="
for f in \
  adapters/vim/colors/retrocrt.vim \
  adapters/nvim/lua/retrocrt.lua \
  adapters/yazi/theme.toml \
  adapters/zsh/retrocrt.zsh
do
  if need_hex "$f" $CANON; then
    ok "$f canonical colors"
  fi
done
# Ghostty has one background surface; BACKGROUND_ALT is unused (documented deviation).
if need_hex adapters/ghostty/retrocrt $BACKGROUND $FOREGROUND $DIM $CYAN $AMBER $MAGENTA $GREEN $RED $BLUE; then
  ok "adapters/ghostty/retrocrt canonical colors"
fi

need_hex adapters/vim/colors/retrocrt.vim $DERIVED && ok "vim derived colors"
need_hex adapters/nvim/lua/retrocrt.lua $DERIVED && ok "nvim derived colors"
need_hex adapters/ghostty/retrocrt "$BRIGHT_RED" "$BRIGHT_CYAN" "$VISUAL_BG" && ok "ghostty ANSI brights"
# tmux: GREEN has no chrome role (documented deviation).
if need_hex adapters/tmux/retrocrt.conf $BACKGROUND $BACKGROUND_ALT $FOREGROUND $DIM $CYAN $AMBER $MAGENTA $RED $BLUE $VISUAL_BG; then
  ok "adapters/tmux/retrocrt.conf canonical colors"
fi

echo
echo "=== vim colorscheme ==="
if command -v vim >/dev/null 2>&1; then
  vimout=$(vim --not-a-term -u NONE -n -es \
    --cmd "set runtimepath+=${ROOT}/adapters/vim" \
    -c "colorscheme retrocrt" \
    -S "${ROOT}/testdata/verify-vim.vim" 2>&1) || rc=$?
  rc=${rc:-0}
  if [ "$rc" -eq 0 ]; then
    ok "vim :colorscheme retrocrt"
  else
    bad "vim colorscheme failed (exit $rc) ${vimout}"
  fi
else
  bad "vim not installed"
fi

echo
echo "=== nvim colorscheme ==="
if command -v nvim >/dev/null 2>&1; then
  nvimout=$(nvim --headless --clean \
    -c "set runtimepath+=${ROOT}/adapters/nvim" \
    -c "colorscheme retrocrt" \
    -c "luafile ${ROOT}/testdata/verify-nvim.lua" 2>&1) || rc=$?
  rc=${rc:-0}
  if [ "$rc" -eq 0 ]; then
    ok "nvim :colorscheme retrocrt + oil/diagnostic groups"
  else
    bad "nvim colorscheme failed (exit $rc) ${nvimout}"
  fi
else
  printf 'SKIP  nvim not installed\n'
fi

echo
echo "=== yazi theme.toml ==="
if command -v yazi >/dev/null 2>&1; then
  ok "yazi binary present (theme is static TOML)"
else
  printf 'SKIP  yazi not installed (theme.toml present)\n'
fi
grep -q 'fg = "#00d4c8"' adapters/yazi/theme.toml && ok "yazi directories cyan"
grep -q 'normal_main' adapters/yazi/theme.toml && ok "yazi mode colors present"
if grep -q 'flavors' adapters/yazi/theme.toml; then
  bad "yazi theme references a flavor pack"
else
  ok "yazi is a manual theme, not a flavor pack"
fi

echo
echo "=== ghostty theme ==="
grep -q 'palette = 6=#00d4c8' adapters/ghostty/retrocrt && ok "ghostty cyan ANSI"
grep -q 'background = #0a0e14' adapters/ghostty/retrocrt && ok "ghostty background"
if grep -Eq 'font-family|window-padding|background-opacity' adapters/ghostty/retrocrt; then
  bad "ghostty adapter contains font/padding/opacity"
else
  ok "ghostty adapter is colors only"
fi

echo
echo "=== zsh adapter ==="
if command -v zsh >/dev/null 2>&1; then
  zsh -f -c "source '${ROOT}/adapters/zsh/retrocrt.zsh' && [[ \$CYAN == '#00d4c8' && \$ZSH_HIGHLIGHT_STYLES[command] == fg=#00d4c8 ]]" \
    && ok "zsh adapter sources" \
    || bad "zsh adapter failed to source"
else
  printf 'SKIP  zsh not installed\n'
fi
grep -q 'syntax-highlighting' adapters/zsh/retrocrt.zsh && ok "zsh adapter documents plugin order"

echo
echo "=== tmux adapter ==="
if grep -q 'bind-key\|bind -' adapters/tmux/retrocrt.conf; then
  bad "tmux adapter contains keybinds"
else
  ok "tmux adapter has no keybinds"
fi
if grep -q 'status-left " #' adapters/tmux/retrocrt.conf && grep -q 'battery' adapters/tmux/retrocrt.conf; then
  ok "tmux status-left is battery"
else
  bad "tmux status-left missing battery"
fi
if grep -q '%Y-%m-%d' adapters/tmux/retrocrt.conf; then
  ok "tmux status-right is date"
else
  bad "tmux status-right missing date"
fi
if grep -Eq '^\s*set(-option)?[[:space:]]+(-[gw]+[[:space:]]+)?-g[[:space:]]+(window-status-format|window-status-current-format)[[:space:]]' adapters/tmux/retrocrt.conf; then
  bad "tmux adapter rewrites window-status-format"
else
  ok "tmux adapter does not rewrite window-status-format"
fi
need_hex adapters/tmux/battery $GREEN $AMBER $RED $DIM && ok "tmux battery uses semantic colors"
if [ -x "${ROOT}/adapters/tmux/battery" ] || [ -f "${ROOT}/adapters/tmux/battery" ]; then
  batout=$(sh "${ROOT}/adapters/tmux/battery") || true
  case "$batout" in
    *BAT*) ok "tmux battery script runs (${batout})" ;;
    *) bad "tmux battery script unexpected: ${batout}" ;;
  esac
fi
if command -v tmux >/dev/null 2>&1; then
  sock=retrocrt-verify
  tmux -L "$sock" kill-server >/dev/null 2>&1 || true
  if ! TMUX= tmux -L "$sock" -f "${ROOT}/adapters/tmux/retrocrt.conf" new-session -d -s verify >/dev/null 2>&1; then
    bad "tmux failed to start with adapter"
  else
    tmuxout=$(tmux -L "$sock" show -gv status-style 2>&1) || true
    case "$tmuxout" in
      *'#121820'*) ok "tmux status-style uses BACKGROUND_ALT" ;;
      *) bad "tmux status-style unexpected: ${tmuxout}" ;;
    esac
    cur=$(tmux -L "$sock" show -gwv window-status-current-style 2>/dev/null || true)
    case "$cur" in
      *'#00d4c8'*) ok "tmux current window is CYAN" ;;
      *) bad "tmux current window style unexpected: ${cur}" ;;
    esac
    mode=$(tmux -L "$sock" show -gwv mode-style 2>/dev/null || true)
    case "$mode" in
      *'#1e3a4c'*) ok "tmux copy-mode uses VISUAL_BG" ;;
      *) bad "tmux mode-style unexpected: ${mode}" ;;
    esac
    msg=$(tmux -L "$sock" show -gv message-style 2>/dev/null || true)
    case "$msg" in
      *'#ffb020'*) ok "tmux command prompt is AMBER" ;;
      *) bad "tmux message-style unexpected: ${msg}" ;;
    esac
    left=$(tmux -L "$sock" show -gv status-left 2>/dev/null || true)
    case "$left" in
      *battery*) ok "tmux status-left calls battery" ;;
      *) bad "tmux status-left unexpected: ${left}" ;;
    esac
    right=$(tmux -L "$sock" show -gv status-right 2>/dev/null || true)
    case "$right" in
      *'%Y-%m-%d'*) ok "tmux status-right is date" ;;
      *) bad "tmux status-right unexpected: ${right}" ;;
    esac
  fi
  tmux -L "$sock" kill-server >/dev/null 2>&1 || true
else
  printf 'SKIP  tmux not installed\n'
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "verify: FAILED"
  exit 1
fi
echo "verify: PASSED"
