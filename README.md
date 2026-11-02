# retrocrt

Universal visual system for this workstation.

Not a product theme pack. Not Warehouse OS / WOS. One palette, semantic roles, small adapters.

Default systems: **Arch Linux** and **FreeBSD**. Main WM: **Sway**. Main terminal: **Ghostty**.

```text
                    retrocrt
                       │
              canonical semantics
                       │
       ┌───────────────┼───────────────┐
       │               │               │
      Vim           Neovim           Yazi
       │               │               │
       │            oil.nvim           │
       │                               │
       └─────────── Ghostty ───────────┘
                       │        (foot: fallback, sway's default $term)
                      tmux              (power status line: optional)
                       │
                      zsh
                       │
                  Powerlevel10k
                       │
                     Sway               (HikaruWM: optional)
                       │
          mako · swaybar · swaylock · swaynag
```

## SYSTEMS

Both default systems run the same adapters and dotfiles. Only these differ:

| | Arch Linux | FreeBSD |
| --- | --- | --- |
| packages | `pacman` | `pkg` |
| Sway default config to copy | `/etc/sway/config` | `/usr/local/etc/sway/config` |
| seat for Sway | logind (systemd) | `seatd` service + user in `video` group |
| `XDG_RUNTIME_DIR` | set by logind | set automatically since FreeBSD 14.1 |
| GPU | kernel driver | `drm-kmod` + `kld_list` (`i915kms`, `amdgpu`, `radeonkms`) |
| battery (tmux, zsh prompt) | `/sys/class/power_supply/BAT*` | `sysctl hw.acpi.battery.*` |
| Vim system clipboard | `+clipboard` in `vim --version` (`gvim` has it): native; otherwise the `wl-copy` fallback | console `vim` has no `+clipboard`: `wl-copy` fallback; `vim-gtk3` has it |

```sh
./install.sh --packages      # prints pacman or pkg + git clone lines for this system
```

It prints, it does not run. Packages: sway, swaylock, swayidle, swaybg, mako, ghostty, foot, wl-clipboard, tmux, zsh, git, fzf, vim, neovim, yazi, a JetBrainsMono Nerd Font; on FreeBSD also seatd, drm-kmod, and sudo (Oh My Zsh's `sudo` plugin). Oh My Zsh, Powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting, and oil.nvim come from `git clone` on both systems (FreeBSD has no Powerlevel10k port).

FreeBSD steps, from the Handbook's Wayland chapter: `sysrc seatd_enable=YES`, `service seatd start`, `pw groupmod video -m <user>`.

Sway: copy the default config, change its terminal line to `set $term ghostty` (the default is `foot`), then `include` the retrocrt colors (see INSTALL).

## NAME

`retrocrt`

## PURPOSE

Shared CRT visual language for terminal, shell, editors, and terminal applications.

Philosophy: manual control, minimal dependencies, readable files, keyboard-first, TUI-oriented.

## PALETTE

Canonical source of truth: [`palette`](./palette)

| Name | HEX | Role |
| --- | --- | --- |
| BACKGROUND | `#0a0e14` | primary surface |
| BACKGROUND_ALT | `#121820` | panels, cursor line, inactive bars |
| FOREGROUND | `#c8d0d8` | normal text |
| DIM | `#5a6570` | comments, metadata, inactive |
| CYAN | `#00d4c8` | active, navigation, commands, NORMAL |
| AMBER | `#ffb020` | editable, attention, warnings, INSERT, strings |
| MAGENTA | `#e040a0` | selection, constants, types, VISUAL |
| GREEN | `#40c070` | success, functions, additions |
| RED | `#e05050` | error, failure, deletions |
| BLUE | `#4080c0` | numbers, informational |

Dominant identity: dark blue-black + cool gray + cyan + amber. Magenta is controlled. Purple is not the identity.

## DERIVED COLORS

Retained from the original Vim colorscheme:

| Name | HEX | Use |
| --- | --- | --- |
| VISUAL_BG | `#1e3a4c` | Visual, MatchParen |
| DIFF_ADD_BG | `#122018` | DiffAdd |
| DIFF_DELETE_BG | `#201212` | DiffDelete |
| DIFF_CHANGE_BG | `#201a10` | DiffChange |

Bright ANSI (same hues, mixed ~20% toward white):

| ANSI | HEX |
| --- | --- |
| bright-black | `#5a6570` (DIM) |
| bright-red | `#e67373` |
| bright-green | `#66cd8d` |
| bright-yellow | `#ffc04d` |
| bright-blue | `#6699cd` |
| bright-magenta | `#e666b3` |
| bright-cyan | `#33ddd3` |
| bright-white | `#d8e0e8` |

## ANSI MAPPING

| Slot | Color |
| --- | --- |
| black | BACKGROUND |
| red | RED |
| green | GREEN |
| yellow | AMBER |
| blue | BLUE |
| magenta | MAGENTA |
| cyan | CYAN |
| white | FOREGROUND |
| bright-black | DIM |
| bright-* | derived brights above |

## CRT STATUS LANGUAGE

| State | Color |
| --- | --- |
| NORMAL | CYAN |
| INSERT | AMBER |
| VISUAL | MAGENTA |
| REPLACE | RED (destructive edit) |

Applied where a mode indicator exists (Vim/Neovim statusline, Yazi mode, p10k vi prompt character, tmux). Not forced onto applications without that concept.

tmux mapping:

| tmux | Role |
| --- | --- |
| active window / pane | NORMAL / CYAN |
| command prompt / messages | INSERT / AMBER |
| copy-mode selection | VISUAL / VISUAL_BG |
| pane in copy-mode | MAGENTA |
| activity | AMBER |
| bell | RED |
| battery healthy | GREEN |
| battery low | AMBER |
| battery critical | RED |
| date | BLUE |

tmux power mapping (optional `adapters/tmux/power.conf`, see TMUX POWER):

| tmux power | Role |
| --- | --- |
| mode pill NORMAL | NORMAL / CYAN |
| mode pill PREFIX, or a key table entered with `switch-client -T` (shown by name) | INSERT / AMBER |
| mode pill COPY (copy-mode), VIEW (view-mode, choose-tree, clock) | VISUAL / MAGENTA |
| mode pill SYNC (synchronize-panes) | AMBER |
| current window | mode color (focus shows the mode) |
| segments B, Y | VISUAL_BG (raised) |
| segments C, D, W, X; inactive windows | BACKGROUND_ALT |
| bar | BACKGROUND (as the swaybar) |
| segment Z (date) | BLUE |
| inactive window text | DIM |
| last window | CYAN text |
| activity / silence | AMBER text |
| bell | RED on DIFF_DELETE_BG (as the swaybar urgent workspace) |
| battery (segment C) | GREEN / AMBER / RED |

Sway mapping:

| Sway | Role |
| --- | --- |
| focused window / workspace | NORMAL / CYAN |
| binding mode | INSERT / AMBER |
| urgent | RED |
| unfocused | DIM |
| mako normal | CYAN border |
| mako critical | RED |
| swaylock idle/typing ring | CYAN |
| swaylock verifying / caps | AMBER |
| swaylock wrong | RED |
| swaylock cleared | GREEN |

HikaruWM mapping:

| Hikaru key | Role |
| --- | --- |
| `color-background` | BACKGROUND |
| `color-focused` | NORMAL / CYAN |
| `color-inactive` (view on an unfocused output) | DIM |
| `color-unfocused` (unfocused view, focused output) | BACKGROUND_ALT |
| `color-urgent` (urgent view, and focused view in a non-NORMAL mode) | INSERT / AMBER |
| mako | shared Sway/mako adapter (CYAN border, RED critical) |
| waylock idle / typing | BACKGROUND / CYAN |
| waylock wrong | RED |

## APPLICATION ADAPTERS

| Application | Adapter | Role |
| --- | --- | --- |
| Vim | `adapters/vim/colors/retrocrt.vim` | lightweight editor theme |
| Neovim | `adapters/nvim/` | IDE theme + oil.nvim + diagnostics |
| oil.nvim | groups in the Neovim adapter | in-editor explorer |
| Yazi | `adapters/yazi/theme.toml` | terminal file manager |
| Ghostty | `adapters/ghostty/retrocrt` | main terminal ANSI/theme |
| foot | `adapters/foot/retrocrt` | fallback terminal (sway's default `$term`; `include=` file) |
| tmux | `adapters/tmux/retrocrt.conf` | status, panes, copy-mode, battery left, date right |
| tmux power (optional) | `adapters/tmux/power.conf` | powerline status line: mode pill, sections, battery left, date right |
| zsh | `adapters/zsh/retrocrt.zsh` | syntax, suggestions, p10k colors only |
| Sway | `adapters/sway/colors` | focused/unfocused/urgent window chrome |
| swaybar | `adapters/sway/bar-colors` | workspaces + binding mode |
| mako | `adapters/mako/config` | notifications |
| swaylock | `adapters/swaylock/config` | lock screen |
| swaynag | `adapters/swaynag/config` | nagbar |
| HikaruWM (optional) | `adapters/hikaru/hikaru.conf.fragment` | `color-*` window border keys |
| waylock (Hikaru) | `adapters/hikaru/hikaru-lock.args` | lock screen flags |

Vim and Neovim stay distinct. Yazi and oil.nvim stay distinct.

## DOTFILES

Personal configs that use the adapters. Installed only with `./install.sh --dotfiles` (existing files are moved to `*.bak.<timestamp>`).

| File | Installed as |
| --- | --- |
| `dotfiles/vim/vimrc` | `~/.vimrc` |
| `dotfiles/nvim/init.lua` | `~/.config/nvim/init.lua` |
| `dotfiles/nvim/lua/config/`, `lua/plugins/` | `~/.config/nvim/lua/config`, `lua/plugins` |
| `dotfiles/nvim/after/ftplugin/` | `~/.config/nvim/after/ftplugin` |
| `dotfiles/zsh/zshrc` | `~/.zshrc` |

Portable on both systems:

- vimrc creates `~/.vim/undo` (Vim does not). Without `+clipboard`, unnamed yanks go to `wl-copy` under Sway; paste with Ctrl+Shift+V in Ghostty.
- Neovim `clipboard=unnamedplus` uses `wl-copy`/`wl-paste` (`wl-clipboard`).
- zshrc battery reads sysfs on Arch and `sysctl` on FreeBSD. Powerlevel10k rebuilds `RPROMPT` on every prompt, so with p10k the battery is a p10k segment (`battery_info`) appended to the right prompt from zshrc; `~/.p10k.zsh` is not edited. p10k's own `battery` segment covers Linux and macOS only.
- zshrc says what to clone when Oh My Zsh is missing; `PATH` uses `$HOME/.local/bin`.

## TMUX POWER

`adapters/tmux/power.conf` is an optional powerline status line, modeled on [wfxr/tmux-power](https://github.com/wfxr/tmux-power) and rebuilt on this palette. It replaces only the status line; panes, messages, and copy-mode stay with `retrocrt.conf`.

```text
+------+---+---+---+-------- windows --------+---+---+---+---+
| MODE | B | C | D |  1:zsh   2:nvim  3:yazi  | W | X | Y | Z |
+------+---+---+---+-------------------------+---+---+---+---+
```

| | tmux-power | retrocrt power |
| --- | --- | --- |
| colors | 9 themes or any hex, gradient `g0`–`g4` | this palette only; no theme option |
| accent | one theme color | mode color: NORMAL CYAN, PREFIX AMBER, COPY MAGENTA, SYNC AMBER |
| prefix / copy indicator | tmux-prefix-highlight plugin | built-in mode pill (section A) |
| implementation | bash script via `run-shell` / TPM | static tmux formats, `source-file`, no script |
| options | set before loading | set before or after (read when the bar is drawn) |
| defaults | `user@host`, session; time, date | mode, session, battery; time, date |

Sections are tmux formats (`#S`, `#h`, `%H:%M`, `#(cmd)`); `''` hides one and the arrows close over it. A thin separator divides two shown segments on the same surface (C|D, W|X).

| Option | Default | Surface |
| --- | --- | --- |
| `@retrocrt_power_mode` | NORMAL / PREFIX / table name / COPY / VIEW / SYNC | mode color |
| `@retrocrt_power_left_b` | `#S` | VISUAL_BG |
| `@retrocrt_power_left_c` | battery script | BACKGROUND_ALT |
| `@retrocrt_power_left_d` | `''` | BACKGROUND_ALT |
| `@retrocrt_power_right_w` | `''` | BACKGROUND_ALT |
| `@retrocrt_power_right_x` | `''` | BACKGROUND_ALT |
| `@retrocrt_power_right_y` | `%H:%M` | VISUAL_BG |
| `@retrocrt_power_right_z` | `%Y-%m-%d` | BLUE |
| `@retrocrt_power_window` | `#I:#W#F` | window text |
| `@retrocrt_power_sep_right` / `_left` | U+E0B0 / U+E0B2 | |
| `@retrocrt_power_sep_right_thin` / `_left_thin` | U+E0B1 / U+E0B3 | |

```tmux
# ~/.tmux.conf
source-file ~/.config/retrocrt/adapters/tmux/retrocrt.conf
source-file ~/.config/retrocrt/adapters/tmux/power.conf
set -g @retrocrt_power_left_d  '#{USER}@#h'       # host on the left, after the battery
set -g @retrocrt_power_right_x '#{pane_current_command}'
set -g @retrocrt_power_sep_right '' # flat blocks, no Nerd Font needed
set -g @retrocrt_power_sep_left  ''
```

Notes:

- A key table entered from the command line (`tmux switch-client -T name`) shows at the next redraw; from a key binding (`bind -n M-r switch-client -T resize`) it shows at once.
- TPM plugins that rewrite tokens such as `#{battery_percentage}` inside `status-left`/`status-right` do not see the tokens in the sections. Put the plugin's `#(script)` in the section instead.
- After `tmux source ~/.tmux.conf`, a section removed from your config keeps its last value until the server restarts (`set -o` keeps set values). Set it to `''` to hide it.

## RULES

How a new application should consume retrocrt:

1. Identify semantic UI roles (background, text, active, warning, error, selection).
2. Map those roles to this palette. Do not invent hues.
3. Add a small adapter under `adapters/`.
4. Check contrast on BACKGROUND.
5. Document any deviation in this file.

Do not download a random marketplace theme.

If the application cannot use the full palette, map the closest roles and note the gap.

Known deviation: foot, like Ghostty, has a single background; `BACKGROUND_ALT` is unused and selection uses `VISUAL_BG`. The file uses `[colors]` (deprecated alias of `[colors-dark]` in foot >= 1.24) so older foot loads it too.

Known deviation: Ghostty has a single background. `BACKGROUND_ALT` is not assigned to an ANSI slot. Selection uses `VISUAL_BG`.

Known deviation: Hikaru has one `color-urgent` key for both urgent views and non-NORMAL modes (resize), so it is AMBER, not RED as in Sway. Hikaru draws no bar or titlebar and `color-*` accepts only `#rrggbb`. A personal `~/.config/mako/config` replaces Hikaru's shipped mako layout entirely; the retrocrt mako adapter is colors only, so re-add font/size/anchor keys if needed. waylock has no config file, so its flags live in `hikaru-lock`; the adapter documents them but `install.sh` does not edit that script.

Known deviation: tmux power uses `VISUAL_BG` as the raised segment surface (B, Y) as well as for copy-mode selection; the palette has no other mid-tone between `BACKGROUND_ALT` and the accents. Its bar is `BACKGROUND` (like the swaybar), not `BACKGROUND_ALT` as in the flat `retrocrt.conf`. `GREEN` reaches it only through the battery. Separators are Powerline glyphs from the Nerd Font in `--packages`; set them to `''` for flat blocks.

Known deviation: Sway window classes have no selection chrome. `MAGENTA` is unused there. waybar / wofi / fuzzel are not Sway's own programs; add them later as separate adapters.

## ANTI-DRIFT

- Change HEX in `palette` first, then adapters.
- Run `./verify.sh` after palette edits.
- Do not introduce synthwave / vaporwave / RGB gaming palettes.
- Do not recolor every file type just because a UI allows it.
- Do not replace `pack/retro` or any hand-managed Neovim packs with Lazy/Packer/vim-plug.
- Do not put fonts, padding, opacity, p10k layout, tmux keybinds, or Sway keybinds into adapters.

## INSTALL

From this repository on the workstation:

```sh
./install.sh --packages      # print the pacman / pkg and git clone lines; run them yourself
./install.sh                 # adapters only; --dry-run shows actions
./install.sh --dotfiles      # adapters + dotfiles/ (vimrc, zshrc, Neovim config)
./install.sh --hikaru-conf   # optional HikaruWM: set color-* in ~/.config/hikaru/hikaru.conf
```

POSIX sh with base utilities, the same on Arch Linux and FreeBSD. No package installs. Not yet run on FreeBSD hardware or in a FreeBSD VM; the FreeBSD paths were checked against the ports tree, the Handbook, and `acpiio.h`.

Then add, if missing:

```text
# ~/.config/ghostty/config — main terminal
theme = retrocrt
```

```text
# ~/.config/sway/config — main WM; copy the default config first
# (Arch /etc/sway/config, FreeBSD /usr/local/etc/sway/config)
set $term ghostty
include ~/.config/retrocrt/adapters/sway/colors
# existing bar: copy adapters/sway/bar-colors into colors { }
# no bar yet: include ~/.config/retrocrt/adapters/sway/bar
```

```tmux
# ~/.tmux.conf
source-file ~/.config/retrocrt/adapters/tmux/retrocrt.conf
# optional powerline status line (after retrocrt.conf):
# source-file ~/.config/retrocrt/adapters/tmux/power.conf
```

Without `--dotfiles`, also:

```vim
" ~/.vimrc
colorscheme retrocrt
```

```lua
-- ~/.config/nvim/init.lua
vim.cmd.colorscheme("retrocrt")
```

```zsh
# ~/.zshrc — after Oh My Zsh, p10k, and zsh-syntax-highlighting (last plugin)
source ~/.config/retrocrt/adapters/zsh/retrocrt.zsh
```

`dotfiles/zsh/zshrc` keeps its own retrocrt token colors and does not source this adapter, so p10k colors stay as `~/.p10k.zsh` sets them.

mako, swaylock, and swaynag load `~/.config/<app>/config` after `./install.sh`.

Required zsh order:

```text
plugins (including autosuggestions, vi-mode)
    ↓
source Oh My Zsh
    ↓
Powerlevel10k
    ↓
zsh-syntax-highlighting     LAST among plugins
    ↓
source retrocrt.zsh         color overlay
```

`install.sh` does not rewrite `~/.p10k.zsh`, Ghostty font/padding/opacity, editor keymaps, tmux keybinds, or Sway keybinds/outputs.

## VALIDATE

```sh
./verify.sh
```

Besides palette and adapters, it installs `--dotfiles` into a throwaway `HOME` and loads the vimrc, the Neovim config, and the zshrc there (including the `wl-copy` fallback when `vim` has no `+clipboard`).

Manual checks:

```text
vim  -c 'colorscheme retrocrt'
nvim -c 'colorscheme retrocrt'
yazi
# Ghostty: theme = retrocrt
# zsh: open a prompt, try vi-mode, a valid command, a typo, a suggestion; battery on the right
# tmux: battery left, date right; copy-mode MAGENTA
# tmux power: pill CYAN NORMAL; prefix AMBER PREFIX; copy-mode MAGENTA COPY; arrows close over empty sections
# sway: set $term ghostty; include adapters/sway/colors; reload
# mako: makoctl reload
# swaylock / swaynag: configs in ~/.config/
# clipboard: yank in vim / nvim, paste in Ghostty with Ctrl+Shift+V
```

---

# Audit (this environment, 2026-09-01)

## CURRENT STATE

This GitHub repository (`D1nDj4r1n/RetroCRT`, description: unified dotfiles) contained only `# RetroCRT` in `README.md`.

Inspected and **not present** in the Cloud Agent home or this repo:

- `~/.vimrc`
- `~/.vim/colors/retrocrt.vim`
- `~/.config/nvim/`
- `~/.config/yazi/`
- `~/.config/ghostty/`
- `~/.zshrc`
- `~/.p10k.zsh`
- `pack/retro`
- `lib/pack.lua`

The visual language in the task (palette, semantic roles, derived colors, CRT status language) is treated as the existing reference. The original Vim colorscheme file was **not available to copy**; the Vim adapter reconstructs it from that reference.

## ALREADY CORRECT

- Canonical HEX values specified in the existing design.
- Derived Vim colors specified and retained.
- Architectural split: Vim vs Neovim, Yazi vs oil.nvim.
- No plugin-manager / flavor-pack dependency in the new adapters.

## DRIFT

- No shared source of truth existed; colors would have to be duplicated per app with no document.
- Workstation configs were not in the repo, so live drift on the machine cannot be measured here.

## DUPLICATION

Adapters intentionally repeat HEX. `palette` is canonical; `./verify.sh` fails if an adapter drops a canonical color.

## MISSING (before this change)

- Canonical palette file
- Neovim / Yazi / Ghostty / zsh adapters
- Design-system document
- ANSI 16 mapping
- Install and verify scripts

## CONFLICTS

None in-repo. Possible on the workstation: an existing `~/.vim/colors/retrocrt.vim` richer than the reconstructed adapter. Merge locally if so.

## USER-SPECIFIC (untouched)

- Fonts, font size, Ghostty padding/opacity/window behavior
- Full `~/.p10k.zsh` layout
- Oh My Zsh plugin list and `bindkey -v`
- Full Vimrc / Neovim IDE (LSP, language packs, keymaps)
- tmux prefix, keybinds, and plugins
- Sway keybinds, outputs, input, gaps, and wallpaper image
- `pack/retro` plugin manager
- oil.nvim and Yazi as separate tools (neither removed)

## RECOMMENDATION (implemented)

Keep a static `palette` plus small adapters. No generator, daemon, or theme framework.
