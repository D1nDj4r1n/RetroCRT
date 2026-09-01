# retrocrt

## Name and purpose

`retrocrt` is the universal visual system for this workstation. It gives
terminal and text applications one restrained CRT-like visual language without
making them share responsibilities or depend on a theme framework.

## Canonical palette

[`palette`](palette) is the source of truth.

| Role | Value | Meaning |
| --- | --- | --- |
| `BACKGROUND` | `#0a0e14` | Primary application surface |
| `BACKGROUND_ALT` | `#121820` | Panels, status bars, inactive areas |
| `FOREGROUND` | `#c8d0d8` | Normal primary text |
| `DIM` | `#5a6570` | Comments, metadata, separators |
| `CYAN` | `#00d4c8` | Active state, navigation, structure, NORMAL mode |
| `AMBER` | `#ffb020` | Attention, pending/editable state, INSERT mode |
| `MAGENTA` | `#e040a0` | Selection, special syntax, VISUAL mode |
| `GREEN` | `#40c070` | Success, healthy/completed state, additions |
| `RED` | `#e05050` | Error, failure, destructive state |
| `BLUE` | `#4080c0` | Informational and secondary structure |

## Derived colors

Supporting surface colors retain the reference Vim design:

- `VISUAL=#1e3a4c`
- `DIFF_ADD_BG=#122018`
- `DIFF_DELETE_BG=#201212`
- `DIFF_CHANGE_BG=#201a10`

ANSI bright colors are conservative lighter derivatives of their base roles.
Bright black is `DIM`; bright white and the six chromatic variants are declared
in `palette`. They exist for terminal compatibility, not as new semantic roles.

## ANSI mapping

| ANSI | retrocrt |
| --- | --- |
| black / bright-black | `BACKGROUND` / `DIM` |
| red / bright-red | `RED` / `BRIGHT_RED` |
| green / bright-green | `GREEN` / `BRIGHT_GREEN` |
| yellow / bright-yellow | `AMBER` / `BRIGHT_AMBER` |
| blue / bright-blue | `BLUE` / `BRIGHT_BLUE` |
| magenta / bright-magenta | `MAGENTA` / `BRIGHT_MAGENTA` |
| cyan / bright-cyan | `CYAN` / `BRIGHT_CYAN` |
| white / bright-white | `FOREGROUND` / `BRIGHT_FOREGROUND` |

## Application adapters

- Vim: `~/.vim/colors/retrocrt.vim` reads the canonical palette directly.
- Neovim: `lua/retrocrt/palette.lua` reads it; `theme.lua` maps UI, syntax,
  diagnostics, status modes, and oil.nvim.
- Yazi: `~/.config/yazi/theme.toml` is a static TOML adapter.
- Ghostty: `themes/retrocrt` maps the canonical and ANSI colors; the main
  config selects it without imposing typography or window preferences.
- zsh: `.zshrc` sources the palette and maps shell semantics. Powerlevel10k
  remains an independent, user-editable prompt adapter.

Static adapters repeat values only where an application's format cannot read the
canonical file. Such values must stay byte-for-byte equivalent to `palette`.

## Rules and anti-drift

For a new application:

1. Identify its semantic UI roles.
2. Map those roles to `retrocrt`; use fewer colors when possible.
3. Add a small local adapter.
4. Validate text contrast, active/inactive hierarchy, and error visibility.
5. Document any unavoidable deviation here.

Do not download an unrelated theme, add arbitrary colors, or make magenta the
dominant identity. Do not add generators, daemons, or theme frameworks merely
to distribute these values. Update `palette` first, then synchronize static
adapters in the same change.
