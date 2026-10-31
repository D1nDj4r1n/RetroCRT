#!/bin/sh
# retrocrt — install adapters (and, with --dotfiles, dotfiles/) into a home directory.
# Default systems: Arch Linux and FreeBSD. Sway is the WM, Ghostty the terminal.
# Does not install packages, plugin managers, or fonts; --packages only prints commands.

set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/retrocrt"

usage() {
  cat <<EOF
install.sh [options]

  --link         symlink this repository to $DEST (default)
  --copy         copy palette, README, adapters, and dotfiles to $DEST
  --dotfiles     also install dotfiles/: ~/.vimrc, ~/.zshrc, and the Neovim
                 config (init.lua, lua/config, lua/plugins, after/ftplugin)
  --packages     print the package and git clone commands for this system, then exit
  --hikaru-conf  rewrite the five color-* lines in ~/.config/hikaru/hikaru.conf
                 (optional HikaruWM; timestamped backup; only if the file exists)
  --dry-run      print actions without changing files
  --help         show this help

Default systems: Arch Linux and FreeBSD (POSIX sh, base utilities only).
Main stack: Sway + Ghostty + tmux + zsh + Vim/Neovim.

Installs visual adapters:
  Vim colorscheme, Neovim colorscheme + oil highlights,
  Yazi theme.toml, Ghostty theme, foot theme, zsh color fragment, tmux styles,
  Sway colors, mako, swaylock, swaynag, HikaruWM colors.
  Sway colors are included, not a full sway config.

Existing files are moved to <name>.bak.<timestamp> before they are replaced.

Adapters do not change: fonts, Ghostty padding/opacity, bindkey,
Oh My Zsh plugin lists, the body of ~/.p10k.zsh, tmux keybinds,
or Sway keybinds/outputs. --dotfiles installs your own vimrc, zshrc,
and Neovim config from this repository; it never touches ~/.p10k.zsh.
EOF
}

detect_system() {
  case $(uname -s 2>/dev/null) in
    FreeBSD) echo freebsd ;;
    Linux)
      id='' like=''
      if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        id=$(. /etc/os-release && printf '%s' "${ID:-}")
        # shellcheck disable=SC1091
        like=$(. /etc/os-release && printf '%s' "${ID_LIKE:-}")
      fi
      case " $id $like " in
        *" arch "*) echo arch ;;
        *) echo linux ;;
      esac
      ;;
    *) echo other ;;
  esac
}

print_packages() {
  # Printed, not run: review, then run the root lines as root.
  user=$(id -un)
  case $SYSTEM in
    arch|freebsd) ;;
    *) printf '# %s is not a default system (Arch Linux, FreeBSD); both lists follow.\n\n' "$SYSTEM" ;;
  esac
  if [ "$SYSTEM" != freebsd ]; then
    cat <<'EOF'
# Arch Linux (as root)
pacman -S --needed sway swaylock swayidle swaybg mako ghostty foot wl-clipboard \
    tmux zsh git fzf vim neovim yazi ttf-jetbrains-mono-nerd

EOF
  fi
  if [ "$SYSTEM" != arch ]; then
    cat <<EOF
# FreeBSD (as root). Sway needs seatd and the video group (FreeBSD Handbook,
# Wayland chapter). XDG_RUNTIME_DIR is set automatically since FreeBSD 14.1.
pkg install sway swaylock swayidle swaybg mako ghostty foot wl-clipboard seatd drm-kmod \\
    tmux zsh git fzf vim neovim yazi nerd-fonts-jetbrainsmono sudo
sysrc seatd_enable=YES
service seatd start
pw groupmod video -m $user
# GPU driver from drm-kmod, one of: sysrc kld_list+=i915kms | amdgpu | radeonkms

EOF
  fi
  cat <<'EOF'
# Both systems (as yourself): what dotfiles/zsh/zshrc and dotfiles/nvim load
git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh ~/.oh-my-zsh
git clone --depth 1 https://github.com/romkatv/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone --depth 1 https://github.com/stevearc/oil.nvim ~/.local/share/nvim/site/pack/retro/start/oil.nvim
chsh -s "$(command -v zsh)"
EOF
}

MODE=link
DRY=0
DOTFILES=0
PACKAGES=0
HIKARU_CONF=0
SYSTEM=$(detect_system)
for arg in "$@"; do
  case "$arg" in
    --link) MODE=link ;;
    --copy) MODE=copy ;;
    --dotfiles) DOTFILES=1 ;;
    --packages) PACKAGES=1 ;;
    --hikaru-conf) HIKARU_CONF=1 ;;
    --dry-run) DRY=1 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "unknown option: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

if [ "$PACKAGES" -eq 1 ]; then
  print_packages
  exit 0
fi

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
echo "os:   $(uname -sr 2>/dev/null) ($SYSTEM)"

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
  run mkdir -p "$DEST/dotfiles"
  run cp -R "$REPO/dotfiles/." "$DEST/dotfiles/"
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

# Dotfiles (opt-in): your vimrc, zshrc, and Neovim config from dotfiles/.
# Neovim gets per-directory links so ~/.config/nvim/lua stays a real directory
# for the adapter's retrocrt.lua and for anything else you keep there.
if [ "$DOTFILES" -eq 1 ]; then
  link_or_copy "$DEST/dotfiles/vim/vimrc" "$HOME/.vimrc"
  run mkdir -p "$HOME/.vim/undo"
  run chmod 700 "$HOME/.vim/undo"
  link_or_copy "$DEST/dotfiles/nvim/init.lua" "$HOME/.config/nvim/init.lua"
  link_or_copy "$DEST/dotfiles/nvim/lua/config" "$HOME/.config/nvim/lua/config"
  link_or_copy "$DEST/dotfiles/nvim/lua/plugins" "$HOME/.config/nvim/lua/plugins"
  link_or_copy "$DEST/dotfiles/nvim/after/ftplugin" "$HOME/.config/nvim/after/ftplugin"
  link_or_copy "$DEST/dotfiles/zsh/zshrc" "$HOME/.zshrc"
fi

echo
if [ "$DOTFILES" -eq 1 ]; then
  echo "Installed visual adapters and dotfiles (vimrc, zshrc, Neovim config)."
else
  echo "Installed visual adapters."
fi
echo
echo "Add these lines if they are not already present:"
echo
echo "  ghostty, main terminal (~/.config/ghostty/config):"
echo "    theme = retrocrt"
echo
echo "  sway, main WM (~/.config/sway/config; start from the default config:"
echo "  Arch /etc/sway/config, FreeBSD /usr/local/etc/sway/config):"
echo "    set \$term ghostty        # the default config sets foot"
echo "    include ${DEST}/adapters/sway/colors"
echo "    # existing bar: copy adapters/sway/bar-colors into colors { }"
echo "    # no existing bar: include ${DEST}/adapters/sway/bar"
echo
echo "  tmux (~/.tmux.conf):"
echo "    source-file ${DEST}/adapters/tmux/retrocrt.conf"
echo
if [ "$DOTFILES" -eq 0 ]; then
  echo "  vim  (~/.vimrc):"
  echo "    colorscheme retrocrt"
  echo
  echo "  nvim (~/.config/nvim/init.lua):"
  echo "    vim.cmd.colorscheme('retrocrt')"
  echo
  echo "  zsh (~/.zshrc) AFTER oh-my-zsh, p10k, and syntax-highlighting:"
  echo "    source ${DEST}/adapters/zsh/retrocrt.zsh"
  echo
fi
echo "  foot, fallback terminal (~/.config/foot/foot.ini, top of file):"
echo "    include=~/.config/foot/themes/retrocrt"
echo
if [ "$HIKARU_CONF" -eq 1 ] || command -v hikaru >/dev/null 2>&1 || [ -d "$HOME/.config/hikaru" ]; then
  echo "  hikaru, optional WM (~/.config/hikaru/hikaru.conf):"
  echo "    re-run with --hikaru-conf, or replace the five color-* lines with"
  echo "    ${DEST}/adapters/hikaru/hikaru.conf.fragment"
  echo "    waylock colors for hikaru-lock: ${DEST}/adapters/hikaru/hikaru-lock.args"
  echo "    note: a personal ~/.config/mako/config replaces Hikaru's shipped mako"
  echo "    layout entirely (font, size, anchor); the retrocrt mako adapter is colors only."
  echo
fi
case $SYSTEM in
  freebsd)
    echo "FreeBSD: Sway needs seatd running and your user in the video group;"
    echo "XDG_RUNTIME_DIR is set automatically since FreeBSD 14.1. The tmux and"
    echo "zsh battery read sysctl hw.acpi.battery.*."
    ;;
  arch)
    echo "Arch Linux: the tmux and zsh battery read /sys/class/power_supply/BAT*."
    ;;
  *)
    echo "$SYSTEM is not a default system (Arch Linux, FreeBSD); adapters still install."
    ;;
esac
echo "Packages and git clones for this system: ./install.sh --packages"
echo
echo "Do not move syntax-highlighting earlier than last among plugins."
