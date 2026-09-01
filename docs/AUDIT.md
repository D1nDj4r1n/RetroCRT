# retrocrt audit

Audit performed before any file was written, then updated with what the
implementation actually did.

## The finding that shapes everything below

**The existing workstation configuration was not reachable from where this work
was done.** The task described auditing `~/.vimrc`, `~/.vim/colors/retrocrt.vim`,
`~/.config/nvim/`, `~/.config/yazi/`, `~/.config/ghostty/`, `~/.zshrc` and
`~/.p10k.zsh`. None of those exist on this machine:

```
$ ls ~/.vimrc ~/.vim ~/.zshrc ~/.p10k.zsh
ls: cannot access '/home/ubuntu/.vimrc': No such file or directory
ls: cannot access '/home/ubuntu/.vim': No such file or directory
ls: cannot access '/home/ubuntu/.zshrc': No such file or directory
ls: cannot access '/home/ubuntu/.p10k.zsh': No such file or directory

$ ls ~/.config
dconf  gh  go  google-chrome  gtk-3.0  plank  xfce4
```

A filesystem-wide search for `retrocrt`, for any of the ten palette hex values,
and for `yazi.toml` / `p10k.zsh` returned nothing. The repository itself was a
single commit containing a one-line `README.md`.

So the audit below is an audit of **the repository**, and the design description
supplied with the task is treated as the reference implementation, since the
file it describes could not be read. Nothing on a running workstation was
inspected, modified or deleted, because nothing was there to inspect.

The practical consequence: `vim/colors/retrocrt.vim` in this repository is a
faithful reconstruction from the documented palette and semantics, not a copy of
the file on the workstation. See **Requires user decision** at the end.

---

## Current state

| Area | Before |
| ---- | ------ |
| Repository | one commit, `README.md` containing `# RetroCRT`, described as "unified dotfiles" |
| Canonical palette | none |
| Vim | absent |
| Neovim | absent |
| Yazi | absent |
| Ghostty | absent |
| zsh | absent (zsh not installed) |
| Documentation | none |
| Drift tooling | none |

Available for validation: Vim 9.1. Installed during the work to validate
against real software: Neovim 0.12.5, zsh 5.9, zsh-syntax-highlighting,
zsh-autosuggestions, oil.nvim.

## Already correct

The palette and its semantics, as supplied. They are internally consistent,
and measurement confirms they are sound rather than merely plausible: every
foreground colour clears the 4.5:1 WCAG floor against `BACKGROUND`, apart from
`DIM` at 3.25:1, which is correct for de-emphasised text. `CYAN` and `AMBER`
land at 10.36 and 10.58, which is why they carry the system.

These values were adopted unchanged. The four derived surface colours from the
original Vim colorscheme were kept and classified as derived, not removed.

## Drift

No drift between applications was possible, because there was only one
application's worth of description and no second implementation to disagree
with it. The real risk identified is *future* drift, since each adapter has to
restate the palette in its own syntax. That is addressed by `retrocrt-check`
rather than by a generator.

Two genuine inconsistencies were found in the source material itself, and both
are resolved and recorded under Deviations in the design document:

- `CYAN` is assigned to "identifiers", which is right for Vim's `Identifier`
  group but wrong for treesitter's `@variable`, where it would paint whole
  files cyan.
- `AMBER` is assigned to search, which leaves no way to distinguish the current
  match from the other matches.

## Duplication

Searched for all ten hex values across the tree. Every occurrence is now
classified, and the classification is machine-checked:

| Location | Classification |
| -------- | -------------- |
| `retrocrt/palette` | canonical |
| `vim/colors/retrocrt.vim` | adapter |
| `nvim/lua/retrocrt/palette.lua` | adapter |
| `ghostty/themes/retrocrt` | adapter |
| `yazi/theme.toml`, `yazi/retrocrt.tmTheme` | adapter |
| `zsh/retrocrt.zsh` | adapter (hex, plus decimal RGB in `LS_COLORS`) |
| `retrocrt/README.md`, `docs/AUDIT.md` | documentation |
| `zsh/p10k.retrocrt.zsh` | no colours at all — ANSI indices only |

The duplication is intentional and unavoidable: no two of these formats can
read a shared file at load time. It is kept honest by `retrocrt-check`, which
fails if any colour anywhere is not in the palette. Generating the adapters was
rejected because it would make every file you read a build artifact.

## Missing

Everything, as of the starting state: canonical palette, all six adapters,
documentation, and any mechanism for detecting drift. All are now implemented.

## Conflicts

None with existing configuration, since there was none. Two constraints from
the task shaped decisions and were honoured:

- No plugin manager. Neovim plugins are plain git checkouts under `pack/retro`,
  managed by `lua/lib/pack.lua`, which provides `:PackEnsure`, `:PackUpdate` and
  `:PackStatus` in about ninety lines and depends on nothing but `git`.
- No Yazi theme pack. `yazi/theme.toml` is hand-written and validated against
  Yazi's official JSON schema.

Two Yazi conflicts were found and resolved during implementation:

- `hovered` and `preview_hovered` have moved out of `[mgr]` into an
  `[indicator]` section. The adapter follows the current schema, and the old
  names are noted in a comment for anyone on an older Yazi.
- Yazi 26.9.1 **refuses to load a theme containing an inline `"$schema"` key**,
  because it validates every top-level key as a section name — even though that
  key appears in Yazi's own shipped preset. This passed JSON-schema validation
  and was only caught by running the real binary. The key was removed;
  validation is done from outside with `taplo` instead.

## User-specific — untouched

- `~/.p10k.zsh` is not rewritten. The overlay sets colour variables only: no
  segment list, no separators, no icons, no layout. `p10k configure` still works.
- Ghostty font, font size, padding, opacity and window behaviour. The theme file
  sets colour and nothing else, and Ghostty loads themes *before* the user
  config, so anything in `~/.config/ghostty/config` still wins.
- `~/.zshrc` itself. `zsh/zshrc.example` documents the required ordering; it is
  not installed over anything.
- Fonts and typography generally.
- Any existing `~/.vimrc` or `~/.config/nvim`. `retrocrt-link` is a dry run by
  default and refuses to overwrite a real file even with `--apply`.

## Requires a decision from you

1. **`vim/colors/retrocrt.vim` is a reconstruction, not your file.** Diff it
   against the real one before installing. `retrocrt-link` will refuse to
   overwrite anything, so nothing is lost either way.
2. **Powerlevel10k segment backgrounds.** The overlay recolours foregrounds
   only. If your p10k style fills segments with colour, those bars still come
   from your `~/.p10k.zsh`. Setting `RETROCRT_P10K_FLAT=1` before sourcing the
   overlay drops them, but that changes the prompt's shape, so it is your call.
3. **`vim/vimrc`, `nvim/init.lua` and `zsh/zshrc.example` are baselines.** They
   implement what the design brief specified, but they cannot preserve settings
   that could not be read. Treat them as a starting point to merge, not as a
   replacement.

## Recommendation, and what was done

The minimal change that produces one coherent system:

1. Make the palette a real file rather than a value repeated in a colorscheme —
   `retrocrt/palette`, plain shell, readable by anything.
2. Keep the Vim colorscheme as the reference implementation and adapt the rest
   to it, rather than redesigning around any one application.
3. Write one small static adapter per application. No generator, no daemon.
4. Add `retrocrt-check` so duplication cannot rot silently.
5. Document the roles, because the roles — not the hex values — are the system.

All five were done. The system is nine adapter and tooling files, one palette,
and two documents.
