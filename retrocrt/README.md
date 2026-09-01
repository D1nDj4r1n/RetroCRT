# retrocrt

**Name** — `retrocrt`. Not a codename for anything else, and unrelated to any
previous project. It names one thing: the visual system this workstation uses.

**Purpose** — one palette and one set of meanings, shared by the terminal, the
shell, both editors and every terminal application. Moving from Ghostty to zsh
to Vim to Neovim to oil.nvim to Yazi should feel like moving around one
machine, not like visiting six applications that each chose their own theme.

The look is retro CRT: a dark blue-black surface, a cool grey foreground, and
phosphor cyan and amber doing most of the work. Magenta is present but
controlled. It is deliberately not synthwave, not neon, and not purple.

---

## Palette

Ten colours. The canonical values live in [`palette`](palette), which is plain
shell and can be sourced or read directly. Nothing else is a retrocrt colour.

| Role             | Hex       | Contrast on BACKGROUND |
| ---------------- | --------- | ---------------------- |
| `BACKGROUND`     | `#0a0e14` | —                      |
| `BACKGROUND_ALT` | `#121820` | 1.08                   |
| `FOREGROUND`     | `#c8d0d8` | 12.41                  |
| `DIM`            | `#5a6570` | 3.25                   |
| `CYAN`           | `#00d4c8` | 10.36                  |
| `AMBER`          | `#ffb020` | 10.58                  |
| `MAGENTA`        | `#e040a0` | 4.98                   |
| `GREEN`          | `#40c070` | 8.28                   |
| `RED`            | `#e05050` | 5.00                   |
| `BLUE`           | `#4080c0` | 4.67                   |

Every foreground colour clears the 4.5:1 readability floor except `DIM`, which
is 3.25:1 on purpose — it is the colour of things you are meant to skim past.
Never use `DIM` for text that has to be read.

Run `retrocrt-preview` to see these in your own terminal with the ratios
recomputed from the palette file.

---

## Semantic roles

The colours mean things. This is the part that has to stay consistent between
applications; the hex values are just how it is spelled.

| Role             | Meaning                                                             |
| ---------------- | ------------------------------------------------------------------- |
| `BACKGROUND`     | primary application surface                                          |
| `BACKGROUND_ALT` | secondary surface: panels, status bars, inactive areas, cursor line  |
| `FOREGROUND`     | normal primary text                                                  |
| `DIM`            | comments, metadata, inactive information, separators                 |
| `CYAN`           | active state, navigation, commands, structure, NORMAL mode           |
| `AMBER`          | editable state, attention, pending state, warnings, INSERT mode      |
| `MAGENTA`        | selection, special syntax, VISUAL mode                               |
| `GREEN`          | success, healthy state, completed state, additions                   |
| `RED`            | error, failure, destructive state                                    |
| `BLUE`           | informational, secondary structural information                      |

In syntax highlighting specifically:

```
CYAN      identifiers, keywords, statements, titles, directories, active statusline
AMBER     strings, characters, cursor line number, search
MAGENTA   constants, booleans, types, preprocessor
GREEN     functions, additions
RED       errors, deletions
BLUE      numbers, informational elements
DIM       comments, line numbers
FOREGROUND  normal text, operators, delimiters
```

### The CRT state language

Where an application has modes, the mode gets a colour, and it is the same
colour everywhere:

```
NORMAL    CYAN        the default, navigating
INSERT    AMBER       editing, something is pending
VISUAL    MAGENTA     a selection exists
```

Extended consistently for modes that only some applications have:

```
REPLACE   RED         destructive editing
COMMAND   BLUE        informational
TERMINAL  GREEN       a live process
```

This appears in the Vim statusline, the Neovim statusline, Yazi's mode
indicator, the Powerlevel10k prompt character, and the shape and colour of the
zsh cursor. Do not force it onto an application that has no real mode.

### Filesystem roles

Four roles, used identically by netrw, oil.nvim, Yazi and `LS_COLORS`:

```
directory    CYAN        navigable structure
executable   GREEN       something that runs
symlink      MAGENTA     special
broken link  RED         error
```

A file does not get a colour for being a `.tar.gz`. Restraint is the point: in
a listing of two hundred entries, colour should mark the few that differ, not
paint all of them.

---

## Derived colours

Supporting values, allowed because they serve a role the ten canonical colours
cannot. Anything not on this list or the list above is drift.

**Surfaces.** Very low-luminance tints of `BACKGROUND`. These are backgrounds
only, never text. They come from the original Vim colorscheme and are kept.

| Name           | Hex       | Used for                       |
| -------------- | --------- | ------------------------------ |
| `SELECTION`    | `#1e3a4c` | Visual, MatchParen, active row |
| `DIFF_ADD_BG`  | `#122018` | added lines                    |
| `DIFF_DEL_BG`  | `#201212` | deleted lines                  |
| `DIFF_CHG_BG`  | `#201a10` | changed lines                  |

**Bright ANSI.** Slots 9–15 need to exist, so each is a conservative lightening
of its canonical hue. No new hues are introduced.

| Name             | Hex       |
| ---------------- | --------- |
| `BRIGHT_RED`     | `#f07070` |
| `BRIGHT_GREEN`   | `#60d890` |
| `BRIGHT_AMBER`   | `#ffc850` |
| `BRIGHT_BLUE`    | `#60a0e0` |
| `BRIGHT_MAGENTA` | `#f060c0` |
| `BRIGHT_CYAN`    | `#40ece0` |
| `BRIGHT_WHITE`   | `#e8f0f8` |

---

## ANSI mapping

This table is the most load-bearing thing in the system. Most terminal
applications cannot be themed at all — they only emit colour indices. Setting
this mapping once in the terminal makes all of them retrocrt for free.

| # | Name           | Colour           | # | Name           | Colour             |
| - | -------------- | ---------------- | - | -------------- | ------------------ |
| 0 | black          | `BACKGROUND`     | 8 | bright black   | `DIM`              |
| 1 | red            | `RED`            | 9 | bright red     | `BRIGHT_RED`       |
| 2 | green          | `GREEN`          | 10 | bright green  | `BRIGHT_GREEN`     |
| 3 | yellow         | `AMBER`          | 11 | bright yellow | `BRIGHT_AMBER`     |
| 4 | blue           | `BLUE`           | 12 | bright blue   | `BRIGHT_BLUE`      |
| 5 | magenta        | `MAGENTA`        | 13 | bright magenta| `BRIGHT_MAGENTA`   |
| 6 | cyan           | `CYAN`           | 14 | bright cyan   | `BRIGHT_CYAN`      |
| 7 | white          | `FOREGROUND`     | 15 | bright white  | `BRIGHT_WHITE`     |

Bright black is `DIM` rather than a near-black, because a great many programs
use colour 8 for secondary text. Making it an actual dark grey would render
that text unreadable.

---

## Application adapters

One adapter per application, each a static file, each restating the palette in
whatever syntax that application accepts.

| Application | Adapter                          | Consumes                          |
| ----------- | -------------------------------- | --------------------------------- |
| Ghostty     | `ghostty/themes/retrocrt`        | hex, and defines the ANSI mapping |
| Vim         | `vim/colors/retrocrt.vim`        | hex + 256-colour fallbacks        |
| Neovim      | `nvim/lua/retrocrt/`             | hex                               |
| oil.nvim    | `nvim/lua/retrocrt/init.lua`     | hex, `Oil*` groups                |
| Yazi        | `yazi/theme.toml`                | hex                               |
| Yazi preview| `yazi/retrocrt.tmTheme`          | hex, via syntect                  |
| zsh         | `zsh/retrocrt.zsh`               | hex + decimal RGB in `LS_COLORS`  |
| p10k        | `zsh/p10k.retrocrt.zsh`          | ANSI indices                      |

### Why the values are duplicated

None of these formats can read a shared file at load time. A generator could
produce them, but then the files you actually read would be build output, and
this is a workshop: `cat` should be enough to understand any of it.

So the duplication is deliberate, and `retrocrt-check` is what keeps it honest.
It scans every tracked file for `#rrggbb` values and `38;2;r;g;b` triples and
fails if any of them is missing from the palette. Adding a colour by hand
without adding it to the palette is a build failure, not a slow drift.

---

## Rules

1. The palette file is the source of truth. Change a colour there first.
2. Map to a **role**, not to a colour. Ask "is this active, pending, an error?"
   and use the role's colour. Never pick a colour because it looks nice here.
3. Adapters may only use canonical or derived colours. `retrocrt-check` enforces this.
4. Prefer ANSI indices when an application cannot take hex. It inherits the
   terminal palette and stays correct automatically.
5. Restraint beats coverage. Not colouring something is a valid decision, and
   usually the right one. Unstyled elements inherit `FOREGROUND` and look fine.
6. Never spend colour on decoration. Colour is a signal; if everything is
   coloured, nothing is.
7. Leave typography alone. Font, size, padding and opacity are personal
   preferences and are not part of this system.

## Adding a new application

```
new application
      v
identify its semantic UI roles      what is active, pending, wrong, secondary?
      v
map those roles to retrocrt         use the tables above
      v
write a minimal adapter             a static file, in the app's own format
      v
run retrocrt-check                  no colour outside the palette
      v
run retrocrt-preview                confirm contrast is adequate
```

Never: download a theme that happens to look similar.

If the application cannot express the whole palette, map to the closest
semantic role available and record the compromise under Deviations below.

## Anti-drift

- No application-specific themes. If Yazi ships a flavor pack that looks close,
  it is still not retrocrt, and next update it will look less close.
- No colour that is not in `palette`. Add it there, with a role, or do not use it.
- No per-file-extension colouring, no colour-per-directory, no rainbow prompts.
- `retrocrt-check` runs clean before any commit.

## Deviations

Places where an adapter knowingly departs from a literal reading of the rules.
Each is a decision, not an oversight.

- **`@variable` is `FOREGROUND`, not `CYAN`.** The role table assigns
  identifiers to `CYAN`, and Vim's classic `Identifier` group is cyan
  accordingly. But treesitter's `@variable` capture matches almost every word
  in a buffer, so honouring it literally would paint whole files cyan and
  destroy the contrast that makes cyan mean "active". Neovim therefore keeps
  `@variable` at `FOREGROUND`.
- **`IncSearch` and `CurSearch` are `CYAN`, while `Search` is `AMBER`.** Amber
  is the search colour; the match you are currently on is the active one, and
  active is cyan. This also makes the current match distinguishable from the
  others, which a single colour cannot do.
- **Powerlevel10k uses ANSI indices, not hex.** p10k takes colour numbers, so
  it inherits the palette through the terminal instead of restating it. This is
  rule 4 working as intended, not a gap.
- **Ghostty is the only adapter allowed to set non-colour options** — and it
  does not use that permission. A theme file is a full config file, so the
  adapter is restricted to colour by convention.
