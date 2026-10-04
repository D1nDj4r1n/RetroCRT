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
  --dry-run  print actions without changing files
  --help     show this help

Installs visual adapters only:
  Vim colorscheme, Neovim colorscheme + oil highlights,
  Yazi theme.toml, Ghostty theme, zsh color fragment, tmux styles,
  mako, swaylock, swaynag, HikaruWM colors. Sway colors are included,
  not a full sway config.

Does not change: fonts, Ghostty padding/opacity, bindkey,
Oh My Zsh plugin lists, the body of ~/.p10k.zsh, tmux keybinds,
or Sway keybinds/outputs.
EOF
}

MODE=link
DRY=0
for arg in "$@"; do
  case "$arg" in
    --link) MODE=link ;;
    --copy) MODE=copy ;;
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

echo "repo: $REPO"
echo "dest: $DEST"
echo "mode: $MODE"

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

# mako / swaylock / swaynag (color configs only; does not replace Sway keybinds)
link_or_copy "$DEST/adapters/mako/config" "$HOME/.config/mako/config"
link_or_copy "$DEST/adapters/swaylock/config" "$HOME/.config/swaylock/config"
link_or_copy "$DEST/adapters/swaynag/config" "$HOME/.config/swaynag/config"

# HikaruWM (color-* fragment and waylock flags are printed below, not installed:
# hikaru.conf and hikaru-lock are personal / installed-by-Hikaru files).
# Hikaru reads mako from ~/.config/mako/config, so the mako adapter above applies.

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
echo "    replace the five color-* lines with ${DEST}/adapters/hikaru/hikaru.conf.fragment"
echo "    waylock colors for hikaru-lock: ${DEST}/adapters/hikaru/hikaru-lock.args"
echo "    note: a personal ~/.config/mako/config replaces Hikaru's shipped mako"
echo "    layout entirely (font, size, anchor); the retrocrt mako adapter is colors only."
echo
echo "Do not move syntax-highlighting earlier than last among plugins."
