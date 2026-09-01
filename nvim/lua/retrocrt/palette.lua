-- retrocrt — palette for the Neovim adapter.
--
-- Canonical values live in ~/.config/retrocrt/palette. They are restated here
-- rather than parsed at startup: a table is faster, has no failure mode, and
-- can be read with `cat`. `retrocrt-check` fails if these drift.

return {
  -- canonical
  bg = '#0a0e14',
  bg_alt = '#121820',
  fg = '#c8d0d8',
  dim = '#5a6570',
  cyan = '#00d4c8',
  amber = '#ffb020',
  magenta = '#e040a0',
  green = '#40c070',
  red = '#e05050',
  blue = '#4080c0',

  -- derived surfaces
  sel = '#1e3a4c',
  add_bg = '#122018',
  del_bg = '#201212',
  chg_bg = '#201a10',

  -- derived bright (ANSI 9-15; ANSI 8 is dim)
  bright_red = '#f07070',
  bright_green = '#60d890',
  bright_amber = '#ffc850',
  bright_blue = '#60a0e0',
  bright_magenta = '#f060c0',
  bright_cyan = '#40ece0',
  bright_white = '#e8f0f8',
}
