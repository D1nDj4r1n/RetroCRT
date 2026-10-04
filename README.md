# retrocrt

Universal visual system for this workstation.

Not a product theme pack. Not Warehouse OS / WOS. One palette, semantic roles, small adapters.

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
       └─────── Ghostty · foot ────────┘
                       │
                      tmux
                       │
                      zsh
                       │
                  Powerlevel10k
                       │
                     Sway · HikaruWM
                       │
          mako · swaybar · swaylock · swaynag
```

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
| Ghostty | `adapters/ghostty/retrocrt` | terminal ANSI/theme |
| foot | `adapters/foot/retrocrt` | terminal ANSI/theme (Hikaru's terminal; `include=` file) |
| tmux | `adapters/tmux/retrocrt.conf` | status, panes, copy-mode, battery left, date right |
| zsh | `adapters/zsh/retrocrt.zsh` | syntax, suggestions, p10k colors only |
| Sway | `adapters/sway/colors` | focused/unfocused/urgent window chrome |
| swaybar | `adapters/sway/bar-colors` | workspaces + binding mode |
| mako | `adapters/mako/config` | notifications |
| swaylock | `adapters/swaylock/config` | lock screen |
| swaynag | `adapters/swaynag/config` | nagbar |
| HikaruWM | `adapters/hikaru/hikaru.conf.fragment` | `color-*` window border keys |
| waylock (Hikaru) | `adapters/hikaru/hikaru-lock.args` | lock screen flags |

Vim and Neovim stay distinct. Yazi and oil.nvim stay distinct.

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
./install.sh                 # adapters only; --dry-run shows actions
./install.sh --hikaru-conf   # also set color-* in ~/.config/hikaru/hikaru.conf (backup kept)
```

Works on Linux and FreeBSD (POSIX sh, base utilities, no package installs). On FreeBSD the tmux battery segment reads `sysctl hw.acpi.battery.*`. Hikaru's own CI covers FreeBSD 14.3 and 15.0; retrocrt installs color files only and has not been run on 15.1 hardware or a VM.

Then add, if missing:

```vim
" ~/.vimrc
colorscheme retrocrt
```

```lua
-- ~/.config/nvim/init.lua
vim.cmd.colorscheme("retrocrt")
```

```text
# ~/.config/ghostty/config
theme = retrocrt
```

```zsh
# ~/.zshrc — after Oh My Zsh, p10k, and zsh-syntax-highlighting (last plugin)
source ~/.config/retrocrt/adapters/zsh/retrocrt.zsh
```

```tmux
# ~/.tmux.conf
source-file ~/.config/retrocrt/adapters/tmux/retrocrt.conf
```

```text
# ~/.config/sway/config
include ~/.config/retrocrt/adapters/sway/colors
# existing bar: copy adapters/sway/bar-colors into colors { }
# no bar yet: include ~/.config/retrocrt/adapters/sway/bar
```

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

Manual checks:

```text
vim  -c 'colorscheme retrocrt'
nvim -c 'colorscheme retrocrt'
yazi
# Ghostty: theme = retrocrt
# zsh: open a prompt, try vi-mode, a valid command, a typo, a suggestion
# tmux: battery left, date right; copy-mode MAGENTA
# sway: include adapters/sway/colors; reload
# mako: makoctl reload
# swaylock / swaynag: configs in ~/.config/
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
