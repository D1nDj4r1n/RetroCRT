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
# Sway clients: MAGENTA unused (no selection chrome). GREEN is on swaylock.
if need_hex adapters/sway/colors $BACKGROUND $BACKGROUND_ALT $FOREGROUND $DIM $CYAN $RED $DIFF_DELETE_BG; then
  ok "adapters/sway/colors canonical colors"
fi
if need_hex adapters/sway/bar-colors $BACKGROUND $BACKGROUND_ALT $FOREGROUND $DIM $CYAN $AMBER $RED $DIFF_DELETE_BG; then
  ok "adapters/sway/bar-colors canonical colors"
fi
if need_hex adapters/mako/config $BACKGROUND_ALT $FOREGROUND $DIM $CYAN $RED $DIFF_DELETE_BG; then
  ok "adapters/mako/config canonical colors"
fi
if need_hex adapters/swaylock/config $BACKGROUND $BACKGROUND_ALT $FOREGROUND $DIM $CYAN $AMBER $GREEN $RED $DIFF_ADD_BG $DIFF_DELETE_BG $DIFF_CHANGE_BG; then
  ok "adapters/swaylock/config canonical colors"
fi
if need_hex adapters/swaynag/config $BACKGROUND $BACKGROUND_ALT $FOREGROUND $CYAN; then
  ok "adapters/swaynag/config canonical colors"
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
echo "=== foot theme ==="
# foot takes RRGGBB without '#'; compare against the palette with it stripped.
foot_ok=1
for hex in $BACKGROUND $FOREGROUND $DIM $CYAN $AMBER $MAGENTA $GREEN $RED $BLUE $VISUAL_BG \
           $BRIGHT_RED $BRIGHT_GREEN $BRIGHT_YELLOW $BRIGHT_BLUE $BRIGHT_MAGENTA $BRIGHT_CYAN $BRIGHT_WHITE; do
  if ! grep -Fq "=${hex#\#}" adapters/foot/retrocrt && ! grep -Fq " ${hex#\#}" adapters/foot/retrocrt; then
    bad "adapters/foot/retrocrt missing ${hex#\#}"
    foot_ok=0
  fi
done
[ "$foot_ok" -eq 1 ] && ok "adapters/foot/retrocrt canonical colors"
grep -q '^regular6=00d4c8$' adapters/foot/retrocrt && ok "foot cyan ANSI"
grep -q '^background=0a0e14$' adapters/foot/retrocrt && ok "foot background"
if grep -Eq '^(font|pad|alpha|term|shell|dpi-aware)' adapters/foot/retrocrt; then
  bad "foot adapter contains font/pad/alpha"
else
  ok "foot adapter is colors only"
fi
if grep -v '^[[:space:]]*#' adapters/foot/retrocrt | grep -q '#'; then
  bad "foot colors must not use a leading #"
else
  ok "foot colors are RRGGBB"
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
if grep -Eq '^[[:space:]]*set(-option)?[[:space:]]+(-[gw]+[[:space:]]+)?-g[[:space:]]+(window-status-format|window-status-current-format)[[:space:]]' adapters/tmux/retrocrt.conf; then
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
echo "=== sway / mako ==="
if grep -q 'bindsym\|bindcode\|exec ' adapters/sway/colors adapters/sway/bar adapters/sway/bar-colors; then
  bad "sway adapter contains binds or exec"
else
  ok "sway adapter is colors only"
fi
grep -q 'client.focused' adapters/sway/colors && ok "sway client.focused present"
grep -q 'binding_mode' adapters/sway/bar-colors && ok "swaybar binding_mode is AMBER"
if grep -q 'font=' adapters/mako/config adapters/swaylock/config adapters/swaynag/config; then
  bad "mako/swaylock/swaynag adapter sets font"
else
  ok "mako/swaylock/swaynag are colors only"
fi
grep -q 'urgency=critical' adapters/mako/config && ok "mako critical urgency present"
grep -q 'ring-color=#00d4c8' adapters/swaylock/config && ok "swaylock ring is CYAN"
grep -q 'border=00d4c8' adapters/swaynag/config && ok "swaynag border is CYAN"
if command -v sway >/dev/null 2>&1; then
  printf 'SKIP  sway --validate needs a full session config\n'
else
  printf 'SKIP  sway not installed\n'
fi
if command -v mako >/dev/null 2>&1; then
  ok "mako binary present"
else
  printf 'SKIP  mako not installed (config is static)\n'
fi

echo
echo "=== hikaru ==="
HC=adapters/hikaru/hikaru.conf.fragment
HL=adapters/hikaru/hikaru-lock.args
if need_hex "$HC" $BACKGROUND $BACKGROUND_ALT $DIM $CYAN $AMBER; then
  ok "$HC canonical colors"
fi
for key in color-background color-focused color-inactive color-unfocused color-urgent; do
  # Hikaru's parser accepts exactly '#' + 6 hex digits.
  if grep -Eq "^${key} #[0-9a-fA-F]{6}\$" "$HC"; then
    ok "hikaru $key is #rrggbb"
  else
    bad "hikaru $key missing or not #rrggbb"
  fi
done
# Every hex in the hikaru adapter must come from the palette.
for f in "$HC" "$HL"; do
  hexes=$(grep -v '^#' "$f" | grep -Eio '(#|0x)[0-9a-f]{6}' | sed 's/^0x/#/' | tr 'A-F' 'a-f' | sort -u)
  for h in $hexes; do
    if ! grep -Eiq "^[A-Z_]+=${h}\$" palette; then
      bad "$f uses $h which is not in palette"
    fi
  done
  ok "$f hex values are in palette"
done
if grep -Eiq '1e1e2e|89b4fa|585b70|313244|f38ba8|cdd6f4' "$HC" "$HL"; then
  bad "hikaru adapter still contains Catppuccin colors"
else
  ok "hikaru adapter has no Catppuccin colors"
fi
if grep -Eq '^(border|focus-border|gap-|cursor|layout|exec |bind)' "$HC"; then
  bad "hikaru adapter sets non-color keys"
else
  ok "hikaru adapter is colors only"
fi
need_hex "$HL" 0x0a0e14 0x00d4c8 0xe05050 && ok "hikaru-lock waylock colors"

echo
echo "=== dotfiles ==="
# Install with --dotfiles into a throwaway HOME, then load each config there.
dothome=$(mktemp -d "${TMPDIR:-/tmp}/retrocrt-verify.XXXXXX")
trap 'rm -rf "$dothome"' EXIT
if env -u XDG_CONFIG_HOME HOME="$dothome" sh "$ROOT/install.sh" --dotfiles >/dev/null 2>&1; then
  ok "install.sh --dotfiles (scratch HOME)"
else
  bad "install.sh --dotfiles failed"
fi
case $(sh "$ROOT/install.sh" --packages) in
  *'git clone'*) ok "install.sh --packages prints commands" ;;
  *) bad "install.sh --packages printed no commands" ;;
esac

if command -v vim >/dev/null 2>&1; then
  if HOME="$dothome" vim --not-a-term -n -es -u "$dothome/.vimrc" \
       -c 'if get(g:, "colors_name", "") !=# "retrocrt" || !isdirectory(expand("~/.vim/undo")) | cquit | endif' \
       -c 'qa!' >/dev/null 2>&1; then
    ok "vimrc loads with colorscheme retrocrt and creates ~/.vim/undo"
  else
    bad "vimrc failed to load"
  fi
  # Console vim (no +clipboard) under Sway: unnamed yanks go to wl-copy.
  if vim --version | grep -q -- '-clipboard'; then
    mkdir -p "$dothome/bin"
    printf '#!/bin/sh\ncat > "%s/wl-copy.out"\n' "$dothome" > "$dothome/bin/wl-copy"
    chmod +x "$dothome/bin/wl-copy"
    printf 'yank me\n' > "$dothome/yank.txt"
    HOME="$dothome" PATH="$dothome/bin:$PATH" WAYLAND_DISPLAY=wayland-verify \
      vim --not-a-term -n -es -u "$dothome/.vimrc" -c '1normal yy' -c 'qa!' "$dothome/yank.txt" >/dev/null 2>&1 || true
    if [ "$(cat "$dothome/wl-copy.out" 2>/dev/null)" = "yank me" ]; then
      ok "vimrc sends yanks to wl-copy when vim has no +clipboard"
    else
      bad "vimrc wl-copy fallback did not receive the yank"
    fi
  else
    printf 'SKIP  vim has +clipboard; wl-copy fallback not used\n'
  fi
fi

if command -v nvim >/dev/null 2>&1; then
  # oil.nvim is a hand-installed pack; its absence is a notice, not a failure.
  # Unset, not empty: Neovim takes an empty XDG_CONFIG_HOME as a relative path.
  nvimout=$(env -u XDG_CONFIG_HOME -u XDG_DATA_HOME -u XDG_STATE_HOME -u XDG_CACHE_HOME \
    HOME="$dothome" nvim --headless \
      -c 'if get(g:, "colors_name", "") !=# "retrocrt" | cquit 1 | endif' \
      -c 'qa!' 2>&1) && rc=0 || rc=$?
  nvimout=$(printf '%s\n' "$nvimout" | grep -v 'oil.nvim' | grep -v '^[[:space:]]*$' || true)
  if [ "$rc" -eq 0 ] && [ -z "$nvimout" ]; then
    ok "nvim init.lua + lua/config + lua/plugins load with colorscheme retrocrt"
  else
    bad "nvim config failed (exit $rc) ${nvimout}"
  fi
else
  printf 'SKIP  nvim not installed\n'
fi

if command -v zsh >/dev/null 2>&1; then
  if zsh -n "$ROOT/dotfiles/zsh/zshrc"; then
    ok "zshrc parses (zsh -n)"
  else
    bad "zshrc has a syntax error"
  fi
  # Without Oh My Zsh / p10k (fresh system): zshrc still defines the battery.
  zout=$(HOME="$dothome" ZDOTDIR="$dothome" zsh -i -c 'whence -w battery_info prompt_battery_info' 2>/dev/null || true)
  case $zout in
    *'battery_info: function'*'prompt_battery_info: function'*) ok "zshrc defines battery_info and the p10k segment" ;;
    *) bad "zshrc battery functions missing: ${zout}" ;;
  esac
else
  printf 'SKIP  zsh not installed\n'
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "verify: FAILED"
  exit 1
fi
echo "verify: PASSED"
