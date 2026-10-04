#!/bin/sh
# retrocrt — install adapters into a workstation home directory.
# Does not install plugin managers, fonts, or rewrite p10k/Ghostty preferences.

set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/retrocrt"

usage() {
  cat <<EOF
install.sh [options]

  --link     symlink this repository to $DEST (default)
  --copy     copy palette, README, and adapters to $DEST
  --hikaru-conf  rewrite the five color-* lines in ~/.config/hikaru/hikaru.conf
                 (timestamped backup; only if the file exists; other keys untouched)
  --dry-run  print actions without changing files
  --help     show this help

Installs visual adapters only:
  Vim colorscheme, Neovim colorscheme + oil highlights,
  Yazi theme.toml, Ghostty theme, foot theme, zsh color fragment, tmux styles,
  mako, swaylock, swaynag, HikaruWM colors. Sway colors are included,
  not a full sway config.

Runs on Linux and FreeBSD (POSIX sh, base utilities only; no package installs).

Does not change: fonts, Ghostty padding/opacity, bindkey,
Oh My Zsh plugin lists, the body of ~/.p10k.zsh, tmux keybinds,
or Sway keybinds/outputs.
EOF
}

MODE=link
DRY=0
HIKARU_CONF=0
OS=$(uname -s 2>/dev/null || echo unknown)
for arg in "$@"; do
  case "$arg" in
    --link) MODE=link ;;
    --copy) MODE=copy ;;
    --hikaru-conf) HIKARU_CONF=1 ;;
    --dry-run) DRY=1 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "unknown option: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

run() {
  if [ "$DRY" -eq 1 ]; then
    printf 'DRY:'
    printf ' %s' "$@"
    printf '\n'
  else
    "$@"
  fi
}

backup_if_real() {
  # If path exists and is not already our symlink, keep a timestamped backup.
  target=$1
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ -L "$target" ]; then
      cur=$(readlink "$target" || true)
      case "$cur" in
        "$REPO"/*|"$DEST"/*) return 0 ;;
      esac
    fi
    bak="${target}.bak.$(date +%Y%m%d%H%M%S)"
    run mv "$target" "$bak"
    echo "backed up $target -> $bak"
  fi
}

link_or_copy() {
  src=$1
  dst=$2
  run mkdir -p "$(dirname "$dst")"
  backup_if_real "$dst"
  if [ "$MODE" = copy ] && [ "$dst" != "$DEST" ]; then
    if [ -d "$src" ]; then
      run cp -R "$src" "$dst"
    else
      run cp "$src" "$dst"
    fi
  else
    run ln -sfn "$src" "$dst"
  fi
}

apply_hikaru_colors() {
  # Replace (or append) the color-* keys from the fragment in a personal
  # hikaru.conf. Writes through symlinks, keeps every other line as is.
  frag="$DEST/adapters/hikaru/hikaru.conf.fragment"
  conf="${XDG_CONFIG_HOME:-$HOME/.config}/hikaru/hikaru.conf"
  [ -f "$frag" ] || frag="$REPO/adapters/hikaru/hikaru.conf.fragment"
  if [ ! -f "$conf" ]; then
    echo "hikaru: $conf not found; copy Hikaru's sample first, then re-run with --hikaru-conf"
    return 0
  fi
  tmp=$(mktemp "${TMPDIR:-/tmp}/retrocrt-hikaru.XXXXXX")
  awk -v frag="$frag" '
    BEGIN {
      while ((getline l < frag) > 0) {
        if (l ~ /^color-[a-z]+ #/) { split(l, a, " "); v[a[1]] = a[2]; order[++n] = a[1] }
      }
    }
    { split($0, b, " ")
      if (b[1] in v) { print b[1], v[b[1]]; seen[b[1]] = 1 } else print }
    END { for (i = 1; i <= n; i++) if (!(order[i] in seen)) print order[i], v[order[i]] }
  ' "$conf" > "$tmp"
  if cmp -s "$tmp" "$conf"; then
    echo "hikaru: colors already set in $conf"
  elif [ "$DRY" -eq 1 ]; then
    echo "DRY: would update color-* in $conf (diff follows)"
    diff "$conf" "$tmp" || true
  else
    bak="${conf}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$conf" "$bak"
    cat "$tmp" > "$conf"
    echo "hikaru: updated color-* in $conf (backup: $bak)"
  fi
  rm -f "$tmp"
}

echo "repo: $REPO"
echo "dest: $DEST"
echo "mode: $MODE"
echo "os:   $OS"

if [ "$MODE" = link ]; then
  if [ "$DEST" != "$REPO" ]; then
    run mkdir -p "$(dirname "$DEST")"
    if [ -e "$DEST" ] || [ -L "$DEST" ]; then
      if [ -L "$DEST" ]; then
        :
      elif [ "$DEST" != "$REPO" ]; then
        backup_if_real "$DEST"
      fi
    fi
    if [ "$DEST" != "$REPO" ]; then
      run ln -sfn "$REPO" "$DEST"
    fi
  fi
else
  run mkdir -p "$DEST/adapters"
  run cp "$REPO/palette" "$DEST/palette"
  run cp "$REPO/README.md" "$DEST/README.md"
  run cp -R "$REPO/adapters/." "$DEST/adapters/"
fi

# Vim adapter
link_or_copy "$DEST/adapters/vim/colors/retrocrt.vim" "$HOME/.vim/colors/retrocrt.vim"

# Neovim adapter (does not replace init.lua)
link_or_copy "$DEST/adapters/nvim/lua/retrocrt.lua" "$HOME/.config/nvim/lua/retrocrt.lua"
link_or_copy "$DEST/adapters/nvim/colors/retrocrt.lua" "$HOME/.config/nvim/colors/retrocrt.lua"

# Yazi adapter (theme only)
link_or_copy "$DEST/adapters/yazi/theme.toml" "$HOME/.config/yazi/theme.toml"

# Ghostty adapter (theme file only; does not edit font/padding/opacity)
run mkdir -p "$HOME/.config/ghostty/themes"
link_or_copy "$DEST/adapters/ghostty/retrocrt" "$HOME/.config/ghostty/themes/retrocrt"

# foot adapter (theme file only; does not edit font/pad/alpha)
run mkdir -p "$HOME/.config/foot/themes"
link_or_copy "$DEST/adapters/foot/retrocrt" "$HOME/.config/foot/themes/retrocrt"

# mako / swaylock / swaynag (color configs only; does not replace Sway keybinds)
link_or_copy "$DEST/adapters/mako/config" "$HOME/.config/mako/config"
link_or_copy "$DEST/adapters/swaylock/config" "$HOME/.config/swaylock/config"
link_or_copy "$DEST/adapters/swaynag/config" "$HOME/.config/swaynag/config"

# HikaruWM: mako above is the file hikaru-autostart reads (~/.config/mako/config).
# hikaru.conf is a personal file, so it is only touched with --hikaru-conf.
# hikaru-lock is installed by Hikaru; its waylock flags are printed below.
if [ "$HIKARU_CONF" -eq 1 ]; then
  apply_hikaru_colors
fi

echo
echo "Installed visual adapters."
echo
echo "Add these lines if they are not already present:"
echo
echo "  vim  (~/.vimrc):"
echo "    colorscheme retrocrt"
echo
echo "  nvim (~/.config/nvim/init.lua):"
echo "    vim.cmd.colorscheme('retrocrt')"
echo
echo "  ghostty (~/.config/ghostty/config):"
echo "    theme = retrocrt"
echo
echo "  foot (~/.config/foot/foot.ini, top of file):"
echo "    include=~/.config/foot/themes/retrocrt"
echo
echo "  zsh (~/.zshrc) AFTER oh-my-zsh, p10k, and syntax-highlighting:"
echo "    source ${DEST}/adapters/zsh/retrocrt.zsh"
echo
echo "  tmux (~/.tmux.conf):"
echo "    source-file ${DEST}/adapters/tmux/retrocrt.conf"
echo
echo "  sway (~/.config/sway/config):"
echo "    include ${DEST}/adapters/sway/colors"
echo "    # existing bar: copy adapters/sway/bar-colors into colors { }"
echo "    # no existing bar: include ${DEST}/adapters/sway/bar"
echo "  hikaru (~/.config/hikaru/hikaru.conf):"
echo "    re-run with --hikaru-conf, or replace the five color-* lines with"
echo "    ${DEST}/adapters/hikaru/hikaru.conf.fragment"
echo "    waylock colors for hikaru-lock: ${DEST}/adapters/hikaru/hikaru-lock.args"
echo "    note: a personal ~/.config/mako/config replaces Hikaru's shipped mako"
echo "    layout entirely (font, size, anchor); the retrocrt mako adapter is colors only."
echo
if [ "$OS" = FreeBSD ]; then
  echo
  echo "FreeBSD: mako, waylock, wbg, and foot come from pkg/ports (see Hikaru"
  echo "docs/RUN/FREEBSD.md). The tmux battery segment reads"
  echo "sysctl hw.acpi.battery.*; Hikaru's CI covers FreeBSD 14.3 and 15.0,"
  echo "retrocrt only installs color files and does not depend on the release."
fi
echo
echo "Do not move syntax-highlighting earlier than last among plugins."
