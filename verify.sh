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
if [ "$fail" -ne 0 ]; then
  echo "verify: FAILED"
  exit 1
fi
echo "verify: PASSED"
