# RetroCRT

Workstation configuration built around one visual system.

The whole point is that Ghostty, zsh, Vim, Neovim, oil.nvim and Yazi share a
single palette and a single set of meanings for it, so the machine looks like
one machine. That system is called **retrocrt** and is specified in
[`retrocrt/README.md`](retrocrt/README.md).

This is a workshop, not a distribution. Everything here is meant to be
understood by reading it. There is no plugin manager, no theme framework, no
generator and no build step.

```
                    retrocrt
                       |
              canonical semantics
                       |
       +---------------+---------------+
       |               |               |
      Vim           Neovim           Yazi
       |               |               |
       |            oil.nvim           |
       |                               |
       +------------ Ghostty ----------+
                       |
                      zsh
                       |
                 Powerlevel10k
```

## Layout

```
retrocrt/
  palette              canonical colours — the source of truth
  README.md            the design system: roles, rules, ANSI mapping
bin/
  retrocrt-check       fail on any colour that is not canonical
  retrocrt-preview     render the palette, with contrast ratios
  retrocrt-link        install the adapters (dry run by default)
vim/
  vimrc                the lightweight editor
  colors/retrocrt.vim  reference implementation of the visual language
nvim/
  init.lua             the IDE
  colors/retrocrt.lua  :colorscheme retrocrt
  lua/retrocrt/        palette and highlight groups
  lua/lib/pack.lua     :PackEnsure / :PackUpdate — the whole plugin system
  lua/config/          options, keymaps, statusline, oil
  pack/retro/opt/      plugins, as plain git checkouts (not committed)
yazi/
  theme.toml           hand-written, validated against Yazi's schema
  retrocrt.tmTheme     so the code preview matches too
ghostty/
  themes/retrocrt      colour only: no font, no padding, no opacity
zsh/
  retrocrt.zsh         highlighting, completion, LS_COLORS, vi-mode cursor
  p10k.retrocrt.zsh    Powerlevel10k colours, nothing else
  zshrc.example        the load order that matters
docs/
  AUDIT.md             what existed, what changed, what was left alone
```

## Roles, kept separate on purpose

| Tool | Job |
| ---- | --- |
| Ghostty | terminal |
| zsh + Powerlevel10k | shell and prompt |
| **Vim** | lightweight editor — system files, git commits, quick edits |
| **Neovim** | the IDE — `alias ide=nvim` |
| **Yazi** | terminal file manager |
| **oil.nvim** | file explorer *inside* Neovim, on `<leader>e` |

Vim is not a small Neovim, and oil.nvim is not a replacement for Yazi. One
edits directories as buffers inside the editor; the other is where you go to
move files around in a terminal. Both exist because both are useful.

## Install

```sh
git clone https://github.com/D1nDj4r1n/RetroCRT.git ~/src/retrocrt
cd ~/src/retrocrt
./bin/retrocrt-link              # dry run: prints what it would do
./bin/retrocrt-link --apply      # link, skipping anything that already exists
```

`retrocrt-link` never overwrites. A real file where a link should go is
reported as a conflict and left alone; `--force` moves it to `.bak-<date>`
first. If you already have a `.vimrc` or an `nvim` config, keep it and take
only the pieces you want.

Two edits are left to you, one line each:

```sh
# ~/.config/ghostty/config
theme = retrocrt

# ~/.zshrc — after Oh My Zsh and after ~/.p10k.zsh
source ~/.config/zsh/retrocrt.zsh
source ~/.config/zsh/p10k.retrocrt.zsh
```

See [`zsh/zshrc.example`](zsh/zshrc.example) for the full ordering, including
the rule that `zsh-syntax-highlighting` must be the last entry in `plugins`.

Neovim plugins:

```
:PackEnsure    clone anything missing
:PackUpdate    pull everything
:PackStatus    list what is installed
```

## Verify

```sh
./bin/retrocrt-check     # no colour outside the palette
./bin/retrocrt-preview   # swatches, contrast ratios, live ANSI mapping
```

Then, by eye:

```sh
vim  -c 'colorscheme retrocrt'          # syntax, statusline, :help, :diffthis
nvim -c 'colorscheme retrocrt'          # then <leader>e for oil
yazi                                    # listing, preview, selection
```

## Adding an application

Identify its semantic roles, map them to retrocrt, write a small static
adapter, run `retrocrt-check`. Do not download a theme that looks close. The
process and the reasoning are in [`retrocrt/README.md`](retrocrt/README.md).
