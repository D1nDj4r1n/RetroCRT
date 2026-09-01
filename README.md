# retrocrt workstation configuration

Handcrafted dotfiles for a keyboard-first, TUI-oriented Linux workstation.
`retrocrt` is the shared visual language; the applications retain separate
roles:

- Vim: lightweight text and system editor
- Neovim: IDE, with oil.nvim as its in-editor explorer
- Yazi: terminal file manager
- Ghostty: terminal layer
- zsh, Oh My Zsh, and Powerlevel10k: interactive shell and prompt

The canonical palette and design rules are documented in
[`.config/retrocrt/README.md`](.config/retrocrt/README.md). Configuration paths
mirror their locations below `$HOME`; deploy them by copying or symlinking the
individual files into the same relative paths. Review existing personal files
before doing so.

Neovim plugins use the native `pack/retro` collection. Run `:PackEnsure` to
install oil.nvim and `:PackUpdate` to fast-forward it. No plugin manager or
theme pack is used.

User-specific Ghostty typography/window options and Powerlevel10k layout choices
belong in their existing files. The tracked Ghostty config selects only the
theme, while `.p10k.zsh` contains only `retrocrt` color overrides.
