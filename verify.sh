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
echo "=== kitty theme (main terminal) ==="
KT=adapters/kitty/retrocrt.conf
# Kitty has a tab bar, so BACKGROUND_ALT has a slot (inactive tabs).
if need_hex "$KT" $CANON $VISUAL_BG $DIFF_DELETE_BG \
     $BRIGHT_RED $BRIGHT_GREEN $BRIGHT_YELLOW $BRIGHT_BLUE $BRIGHT_MAGENTA $BRIGHT_CYAN $BRIGHT_WHITE; then
  ok "$KT canonical colors"
fi
grep -q '^color6 #00d4c8$' "$KT" && ok "kitty cyan ANSI" || bad "kitty color6 is not CYAN"
grep -q '^background #0a0e14$' "$KT" && ok "kitty background" || bad "kitty background is not BACKGROUND"
grep -q '^cursor #00d4c8$' "$KT" && ok "kitty cursor is CYAN (NORMAL)" || bad "kitty cursor is not CYAN"
grep -q '^active_tab_background #00d4c8$' "$KT" && ok "kitty active tab is CYAN" || bad "kitty active tab is not CYAN"
kitty_n=0
while read -r k; do
  grep -q "^$k #" "$KT" || { bad "kitty missing $k"; kitty_n=1; }
done <<EOF
foreground
selection_background
color0
color15
inactive_tab_background
bell_border_color
EOF
[ "$kitty_n" -eq 0 ] && ok "kitty has colors 0-15, selection, tabs, borders"
# kitty.conf syntax: "key value", one per line; inline comments are not allowed.
if grep -v '^[[:space:]]*#' "$KT" | grep -v '^[[:space:]]*$' | grep -Eqv '^[a-z0-9_]+ #[0-9a-f]{6}$'; then
  bad "kitty adapter has a line that is not 'key #rrggbb'"
else
  ok "kitty lines are 'key #rrggbb'"
fi
kitty_hex_ok=1
for h in $(grep -v '^[[:space:]]*#' "$KT" | grep -Eo '#[0-9a-f]{6}' | sort -u); do
  if ! grep -Eiq "^[A-Z_]+=${h}\$" palette; then
    bad "$KT uses $h which is not in palette"
    kitty_hex_ok=0
  fi
done
[ "$kitty_hex_ok" -eq 1 ] && ok "$KT hex values are in palette"
if grep -Eq '^(font_|font_size|window_padding|background_opacity|shell_integration|include|map )' "$KT"; then
  bad "kitty adapter contains font/padding/opacity/shell integration/binds"
else
  ok "kitty adapter is colors only"
fi
grep -q '^## name: retrocrt' "$KT" && ok "kitty theme is listed by kitty +kitten themes"
if command -v kitty >/dev/null 2>&1; then
  ok "kitty binary present"
else
  printf 'SKIP  kitty not installed (theme is static)\n'
fi
grep -q 'set \$term kitty' adapters/sway/sway.conf.fragment && ok "sway \$term is kitty" || bad "sway fragment does not set \$term kitty"

echo
echo "=== ghostty theme (optional) ==="
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

# Battery on both default systems, laptop and PC, without the hardware:
# a fake sysfs for Arch, fake uname/sysctl for FreeBSD.
fx=$(mktemp -d "${TMPDIR:-/tmp}/retrocrt-battery.XXXXXX")
fake_ps() { # dir name key value ...
  d="$fx/$1/$2"
  mkdir -p "$d"
  shift 2
  while [ $# -gt 1 ]; do printf '%s\n' "$2" > "$d/$1"; shift 2; done
}
fake_ps arch-laptop AC type Mains online 1
fake_ps arch-laptop BAT0 type Battery capacity 87 status Charging present 1
fake_ps arch-laptop hidpp_battery_0 type Battery scope Device capacity 40
fake_ps arch-pc AAA_gamepad type Battery scope Device capacity 55
fake_ps arch-pc ACAD type Mains online 1
mkdir -p "$fx/none" "$fx/bsd-laptop" "$fx/bsd-pc"
for b in bsd-laptop bsd-pc; do
  printf '#!/bin/sh\necho FreeBSD\n' > "$fx/$b/uname"
done
printf '#!/bin/sh\ncase "$2" in hw.acpi.battery.life) echo 28 ;; hw.acpi.battery.state) echo 1 ;; *) exit 1 ;; esac\n' > "$fx/bsd-laptop/sysctl"
printf '#!/bin/sh\necho "sysctl: unknown oid" >&2\nexit 1\n' > "$fx/bsd-pc/sysctl"
chmod +x "$fx"/bsd-*/*
bat() { # sysfs-dir path-prefix mode
  RETROCRT_POWER_SUPPLY="$fx/$1" PATH="$2$PATH" sh "${ROOT}/adapters/tmux/battery" "$3"
}
bat_case() { # label expected sysfs-dir path-prefix mode
  got=$(bat "$3" "$4" "$5")
  if [ "$got" = "$2" ]; then
    ok "battery $1 $5: ${got:-(nothing)}"
  else
    bad "battery $1 $5: expected '${2}' got '${got}'"
  fi
}
bat_case "Arch laptop"  "#[fg=$GREEN]BAT 87%+" arch-laptop "" auto
bat_case "Arch laptop"  "#[fg=$GREEN]BAT 87%+" arch-laptop "" on
bat_case "Arch laptop"  ""                     arch-laptop "" off
bat_case "Arch PC (gamepad battery only)" ""   arch-pc     "" auto
bat_case "Arch PC (gamepad battery only)" "#[fg=$DIM]BAT --" arch-pc "" on
bat_case "FreeBSD laptop" "#[fg=$AMBER]BAT 28%" none "$fx/bsd-laptop:" auto
bat_case "FreeBSD PC"     ""                    none "$fx/bsd-pc:"     auto
bat_case "FreeBSD PC"     ""                    none "$fx/bsd-pc:"     off
bat_case "FreeBSD PC"     "#[fg=$DIM]BAT --"    none "$fx/bsd-pc:"     on
rm -rf "$fx"

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
    case "$msg" in
      *'fill=#ffb020'*) ok "tmux prompt fills the line (tmux >= 3.7)" ;;
      *) bad "tmux message-style has no fill: ${msg}" ;;
    esac
    case "$(tmux -L "$sock" show -gv terminal-features 2>/dev/null)" in
      *'xterm-kitty:utf8'*) ok "tmux treats Kitty as UTF-8 (tmux >= 3.8)" ;;
      *) bad "tmux terminal-features lacks xterm-kitty:utf8" ;;
    esac
    [ "$(tmux -L "$sock" show -gv @retrocrt_battery 2>/dev/null)" = auto ] \
      && ok "tmux @retrocrt_battery defaults to auto" || bad "tmux @retrocrt_battery is not auto"
    tmux -L "$sock" set -g @retrocrt_battery off
    [ "$(tmux -L "$sock" display -p '#{T:status-left}')" = "  " ] \
      && ok "tmux @retrocrt_battery off: no battery (PC)" || bad "tmux @retrocrt_battery off still calls battery"
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
echo "=== tmux power (default status line) ==="
TP=adapters/tmux/power.conf
if grep -q '^source-file .*/adapters/tmux/power.conf' adapters/tmux/tmux.conf.fragment; then
  ok "tmux.conf.fragment sources power.conf"
else
  bad "tmux.conf.fragment does not source power.conf (bar stays flat)"
fi
if grep -Eq '^[[:space:]]*(bind|bind-key|unbind|unbind-key|run|run-shell)[[:space:]]' "$TP"; then
  bad "$TP contains keybinds or run-shell"
else
  ok "$TP has no keybinds or run-shell"
fi
# GREEN reaches the bar through the battery script.
if need_hex "$TP" $BACKGROUND $BACKGROUND_ALT $FOREGROUND $DIM $CYAN $AMBER $MAGENTA $RED $BLUE $VISUAL_BG $DIFF_DELETE_BG; then
  ok "$TP canonical colors"
fi
power_hex_ok=1
for h in $(grep -Eio '#[0-9a-f]{6}' "$TP" | tr 'A-F' 'a-f' | sort -u); do
  if ! grep -Eiq "^[A-Z_]+=${h}\$" palette; then
    bad "$TP uses $h which is not in palette"
    power_hex_ok=0
  fi
done
[ "$power_hex_ok" -eq 1 ] && ok "$TP hex values are in palette"
# Uppercase hex breaks inside tmux formats: #D is pane_id, #F window_flags.
if grep -Eo '#[0-9a-fA-F]{6}' "$TP" | grep -q '[A-F]'; then
  bad "$TP has uppercase hex (tmux expands #D, #F, ...)"
else
  ok "$TP hex is lowercase"
fi
if grep -q 'client_utf8,\\ue0b0,' "$TP"; then
  ok "$TP separators are \\u escapes"
else
  bad "$TP separators are not \\u escapes (raw glyphs or no UTF-8 fallback)"
fi
if command -v tmux >/dev/null 2>&1; then
  psock=retrocrt-verify-power
  pt() { tmux -u -L "$psock" "$@"; }
  strip_styles() { sed 's/#\[[^]]*\]//g'; }
  tmux -L "$psock" kill-server >/dev/null 2>&1 || true
  if ! TMUX= tmux -L "$psock" -f "${ROOT}/adapters/tmux/retrocrt.conf" new-session -d -s verify >/dev/null 2>&1; then
    bad "tmux failed to start for power"
  elif ! pt source-file "${ROOT}/$TP" >/dev/null 2>&1; then
    bad "tmux power.conf failed to source"
  else
    ok "tmux sources retrocrt.conf + power.conf"
    left=$(pt display -p '#{T:status-left}' | strip_styles)
    case "$left" in
      *' NORMAL '*' verify '*) ok "power left: NORMAL pill, then session" ;;
      *) bad "power left unexpected: ${left}" ;;
    esac
    case "$(pt show -gv @retrocrt_power_left_c)" in
      *battery*) ok "power left C is the battery" ;;
      *) bad "power left C is not the battery" ;;
    esac
    right=$(pt display -p '#{T:status-right}' | strip_styles)
    case "$right" in
      *"$(date +%Y-%m-%d)"*) ok "power right ends with the date" ;;
      *) bad "power right unexpected: ${right}" ;;
    esac
    case "$(pt display -p '#{T:status-right}')" in
      *'#[bg=#4080c0]'*) ok "power date is BLUE" ;;
      *) bad "power date is not BLUE" ;;
    esac
    [ "$(pt display -p '#{E:@retrocrt_power_mode_color}')" = "$CYAN" ] \
      && ok "power NORMAL is CYAN" || bad "power NORMAL is not CYAN"
    pt set -w synchronize-panes on
    case "$(pt display -p '#{E:@retrocrt_power_mode}') $(pt display -p '#{E:@retrocrt_power_mode_color}')" in
      "SYNC $AMBER") ok "power SYNC is AMBER" ;;
      *) bad "power synchronize-panes not SYNC/AMBER" ;;
    esac
    pt set -w synchronize-panes off
    pt copy-mode
    case "$(pt display -p '#{E:@retrocrt_power_mode}') $(pt display -p '#{E:@retrocrt_power_mode_color}')" in
      "COPY $MAGENTA") ok "power COPY is MAGENTA" ;;
      *) bad "power copy-mode not COPY/MAGENTA" ;;
    esac
    pt send-keys -X cancel
    case "$(pt display -p '#{T:window-status-current-format}')" in
      *"bg=$CYAN"*) ok "power current window takes the mode color" ;;
      *) bad "power current window does not take the mode color" ;;
    esac
    # Empty B: the pill's separator goes straight onto C (BACKGROUND_ALT).
    # display -p does not run #() jobs, so C is a fixed string here.
    pt set -g @retrocrt_power_left_c 'C'
    pt set -g @retrocrt_power_left_b ''
    case "$(pt display -p '#{T:status-left}')" in
      *"$VISUAL_BG"*) bad "power empty B still draws VISUAL_BG" ;;
      *"#[fg=$CYAN]#[bg=$BACKGROUND_ALT]"*) ok "power empty section is skipped" ;;
      *) bad "power empty B: unexpected transition" ;;
    esac
    # A section that renders empty is hidden like an empty one (PC battery).
    pt set -g @retrocrt_power_left_c '#{?0,x,}'
    case "$(pt display -p '#{T:status-left}')" in
      *"$BACKGROUND_ALT"*) bad "power section rendering empty still draws a segment" ;;
      *) ok "power section rendering empty is hidden" ;;
    esac
    pt set -gu @retrocrt_power_left_c
    pt source-file "${ROOT}/$TP" >/dev/null 2>&1 || true
    case "$(pt show -gv @retrocrt_power_left_c)" in
      *'battery #{@retrocrt_battery}'*) ok "power C passes @retrocrt_battery to the battery" ;;
      *) bad "power C does not pass @retrocrt_battery" ;;
    esac
    [ "$(pt show -gv @retrocrt_battery)" = auto ] \
      && ok "power @retrocrt_battery defaults to auto" || bad "power @retrocrt_battery is not auto"
    pt set -g @retrocrt_battery off
    [ "$(pt display -p '#{E:@retrocrt_power_show_c}')" = 0 ] \
      && ok "power @retrocrt_battery off hides C (PC)" || bad "power @retrocrt_battery off does not hide C"
    case "$(pt show -gv @retrocrt_power_sep_right)" in
      *"$(printf '\356\202\260')"*) ok "power separator is U+E0B0" ;;
      *) bad "power separator is not U+E0B0" ;;
    esac
    # No UTF-8 client (display -p has none): no glyph, '|' for thin.
    [ -z "$(pt display -p '#{E:@retrocrt_power_sep_right}')" ] && [ "$(pt display -p '#{E:@retrocrt_power_sep_right_thin}')" = '|' ] \
      && ok "power separators fall back without UTF-8" || bad "power separators have no non-UTF-8 fallback"
  fi
  tmux -L "$psock" kill-server >/dev/null 2>&1 || true
  # A section set before sourcing survives (set -o).
  if TMUX= tmux -L "$psock" -f /dev/null new-session -d -s verify >/dev/null 2>&1; then
    pt set -g @retrocrt_power_left_b 'PRESET'
    pt source-file "${ROOT}/$TP" >/dev/null 2>&1 || true
    case "$(pt display -p '#{T:status-left}' | strip_styles)" in
      *PRESET*) ok "power keeps a section set before sourcing" ;;
      *) bad "power overwrote a section set before sourcing" ;;
    esac
  fi
  tmux -L "$psock" kill-server >/dev/null 2>&1 || true
else
  printf 'SKIP  tmux not installed\n'
fi

echo
echo "=== waybar (FreeBSD bar) ==="
WC=adapters/waybar/retrocrt.css
WD=dotfiles/waybar
if need_hex "$WC" $CANON $VISUAL_BG $DIFF_DELETE_BG; then
  ok "$WC canonical colors"
fi
wb_hex_ok=1
for h in $(grep -Eo '#[0-9a-fA-F]{6}' "$WC" | tr 'A-F' 'a-f' | sort -u); do
  if ! grep -Eiq "^[A-Z_]+=${h}\$" palette; then
    bad "$WC uses $h which is not in palette"
    wb_hex_ok=0
  fi
done
[ "$wb_hex_ok" -eq 1 ] && ok "$WC hex values are in palette"
if grep -Eq '^[[:space:]]*(font|padding|margin|border-radius|border-width|min-height|border:)' "$WC"; then
  bad "waybar adapter sets font/padding/margins/borders"
else
  ok "waybar adapter is colors only"
fi
grep -q '#workspaces button.focused' "$WC" && grep -A3 '#workspaces button.focused' "$WC" | grep -q 'retrocrt_cyan' \
  && ok "waybar focused workspace is CYAN" || bad "waybar focused workspace is not CYAN"
grep -A3 '^#mode' "$WC" | grep -q 'retrocrt_amber' && ok "waybar binding mode is AMBER" || bad "waybar mode is not AMBER"
grep -A3 '^#clock' "$WC" | grep -q 'retrocrt_blue' && ok "waybar date is BLUE" || bad "waybar clock is not BLUE"
grep -q '^@import "retrocrt.css";' "$WD/style.css" && ok "waybar style.css imports the adapter" || bad "waybar style.css does not import retrocrt.css"

# config.jsonc: full-line // comments only, so stripping them gives JSON.
if command -v jq >/dev/null 2>&1; then
  wbcfg=$(sed 's#^[[:space:]]*//.*$##' "$WD/config.jsonc")
  if printf '%s\n' "$wbcfg" | jq -e . >/dev/null 2>&1; then
    ok "waybar config.jsonc is valid JSONC"
    mods=$(printf '%s\n' "$wbcfg" | jq -r '.["modules-left"][], .["modules-center"][], .["modules-right"][]')
    # Not built by the FreeBSD port (no libnl) or not for a PC / without a daemon.
    wb_mod_ok=1
    for m in network battery pulseaudio wireplumber backlight bluetooth upower systemd-failed-units; do
      if printf '%s\n' "$mods" | grep -qx "$m"; then
        bad "waybar config uses $m (not for FreeBSD/PC)"
        wb_mod_ok=0
      fi
    done
    [ "$wb_mod_ok" -eq 1 ] && ok "waybar modules are FreeBSD-only, no battery (PC)"
    for m in $mods; do
      printf '%s\n' "$wbcfg" | jq -e --arg m "$m" 'has($m)' >/dev/null 2>&1 \
        || { case $m in sway/*|tray|cpu|memory) ;; *) bad "waybar module $m has no settings" ;; esac; }
    done
    case $mods in
      *custom/net*custom/audio*clock*) ok "waybar right: net, audio, ..., date last" ;;
      *) bad "waybar modules-right order unexpected" ;;
    esac
  else
    bad "waybar config.jsonc is not valid JSONC"
  fi
else
  printf 'SKIP  jq not installed (waybar config.jsonc not parsed)\n'
fi

# Scripts against fake FreeBSD route(8), ifconfig(8), mixer(8).
wbf=$(mktemp -d "${TMPDIR:-/tmp}/retrocrt-waybar.XXXXXX")
wb_tool() { # case name body
  mkdir -p "$wbf/$1"
  printf '#!/bin/sh\n%s\n' "$3" > "$wbf/$1/$2"
  chmod +x "$wbf/$1/$2"
}
wb_tool eth route 'printf "   route to: default\n    gateway: 192.168.1.1\n  interface: em0\n"'
wb_tool eth ifconfig 'printf "em0: flags=8843<UP> mtu 1500\n\tinet 192.168.1.10 netmask 0xffffff00\n\tstatus: active\n"'
wb_tool eth mixer 'case "$1" in vol.volume) echo vol.volume=0.75:0.75 ;; vol.mute) echo vol.mute=off ;; esac'
wb_tool wifi route 'printf "  interface: wlan0\n"'
wb_tool wifi ifconfig 'printf "wlan0: flags=8843<UP> mtu 1500\n\tinet 10.0.0.42 netmask 0xffffff00\n\tssid \"Dom 5G\" channel 36 (5180 MHz 11a) bssid 11:22:33:44:55:66\n"'
wb_tool wifi mixer 'case "$1" in vol.volume) echo vol.volume=0.30:0.30 ;; vol.mute) echo vol.mute=on ;; esac'
wb_tool off route 'exit 1'
wb_tool off ifconfig 'exit 1'
wb_tool off mixer 'echo "mixer: /dev/mixer: No such file" >&2; exit 1'
wb_case() { # label case script expected-text expected-class
  out=$(PATH="$wbf/$2:$PATH" sh "${ROOT}/$WD/scripts/$3")
  if command -v jq >/dev/null 2>&1; then
    got=$(printf '%s' "$out" | jq -r '"\(.text)|\(.class)"' 2>/dev/null || echo "invalid JSON: $out")
  else
    got=$out
  fi
  case $got in
    "$4|$5"|*"\"text\":\"$4\""*"\"class\":\"$5\""*) ok "waybar $3 $1: $4 ($5)" ;;
    *) bad "waybar $3 $1: expected '$4|$5' got '$got'" ;;
  esac
}
wb_case "wired"        eth  net   "NET em0 192.168.1.10" up
wb_case "Wi-Fi"        wifi net   "NET Dom 5G"           wifi
wb_case "no route"     off  net   "NET --"               down
wb_case "75%"          eth  audio "VOL 75%"              on
wb_case "muted"        wifi audio "VOL mute"             muted
wb_case "no mixer"     off  audio "VOL --"               none
rm -rf "$wbf"
[ -x "$WD/scripts/net" ] && [ -x "$WD/scripts/audio" ] && ok "waybar scripts are executable" || bad "waybar scripts are not executable"

# GTK's own CSS parser, as Waybar loads it (needs libgtk-3 and python3).
if command -v python3 >/dev/null 2>&1 && python3 -I -c 'import ctypes; ctypes.CDLL("libgtk-3.so.0")' >/dev/null 2>&1; then
  wbcss=$(mktemp -d "${TMPDIR:-/tmp}/retrocrt-waybar-css.XXXXXX")
  cp "$WC" "$WD/style.css" "$wbcss/"
  if python3 -I "${ROOT}/testdata/gtk-css-check.py" "$wbcss/style.css" >/dev/null 2>&1; then
    ok "waybar style.css + retrocrt.css load in GTK 3"
  else
    bad "waybar CSS has GTK parse errors: $(python3 -I "${ROOT}/testdata/gtk-css-check.py" "$wbcss/style.css" 2>/dev/null | head -3)"
  fi
  rm -rf "$wbcss"
else
  printf 'SKIP  libgtk-3 not available (waybar CSS not parsed)\n'
fi
if command -v waybar >/dev/null 2>&1; then
  ok "waybar binary present"
else
  printf 'SKIP  waybar not installed (FreeBSD: pkg install waybar)\n'
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
