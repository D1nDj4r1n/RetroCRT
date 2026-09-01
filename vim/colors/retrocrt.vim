" retrocrt — Vim adapter
"
" Canonical palette: ~/.config/retrocrt/palette
" Semantic roles:    ~/.config/retrocrt/README.md
"
" Vim cannot read the canonical palette at load time, so the values are
" restated below. Each colour appears exactly once in this file; `retrocrt-check`
" verifies that every one of them is canonical.

set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "retrocrt"

" Each entry is [gui, cterm]. The cterm values are the closest 256-colour
" approximations and are only used on terminals without truecolor.
let s:bg      = ['#0a0e14', 233]
let s:bg_alt  = ['#121820', 234]
let s:fg      = ['#c8d0d8', 252]
let s:dim     = ['#5a6570', 241]
let s:cyan    = ['#00d4c8',  44]
let s:amber   = ['#ffb020', 214]
let s:magenta = ['#e040a0', 169]
let s:green   = ['#40c070',  78]
let s:red     = ['#e05050', 167]
let s:blue    = ['#4080c0',  68]

let s:sel     = ['#1e3a4c', 236]
let s:add_bg  = ['#122018',  22]
let s:del_bg  = ['#201212',  52]
let s:chg_bg  = ['#201a10',  58]

let s:none    = ['NONE', 'NONE']

" s:hi(group, fg, bg, attr [, sp])
function! s:hi(group, fg, bg, attr, ...) abort
  let l:cmd = 'highlight ' . a:group
        \ . ' guifg='   . a:fg[0] . ' guibg='   . a:bg[0]
        \ . ' ctermfg=' . a:fg[1] . ' ctermbg=' . a:bg[1]
        \ . ' gui='     . a:attr  . ' cterm='   . a:attr
  if a:0
    let l:cmd .= ' guisp=' . a:1[0]
  endif
  execute l:cmd
endfunction

" --- editor surfaces ---------------------------------------------------------
call s:hi('Normal',       s:fg,      s:bg,     'NONE')
call s:hi('NonText',      s:dim,     s:none,   'NONE')
call s:hi('EndOfBuffer',  s:dim,     s:none,   'NONE')
call s:hi('SpecialKey',   s:dim,     s:none,   'NONE')
call s:hi('Whitespace',   s:dim,     s:none,   'NONE')
call s:hi('Conceal',      s:dim,     s:none,   'NONE')
call s:hi('ColorColumn',  s:none,    s:bg_alt, 'NONE')
call s:hi('CursorColumn', s:none,    s:bg_alt, 'NONE')
call s:hi('CursorLine',   s:none,    s:bg_alt, 'NONE')
call s:hi('Cursor',       s:bg,      s:cyan,   'NONE')
call s:hi('lCursor',      s:bg,      s:cyan,   'NONE')
call s:hi('LineNr',       s:dim,     s:none,   'NONE')
call s:hi('CursorLineNr', s:amber,   s:bg_alt, 'bold')
call s:hi('SignColumn',   s:dim,     s:none,   'NONE')
call s:hi('FoldColumn',   s:dim,     s:none,   'NONE')
call s:hi('Folded',       s:dim,     s:bg_alt, 'NONE')
call s:hi('VertSplit',    s:dim,     s:none,   'NONE')
call s:hi('Directory',    s:cyan,    s:none,   'NONE')
call s:hi('Title',        s:cyan,    s:none,   'bold')

" --- selection and search ----------------------------------------------------
call s:hi('Visual',       s:none,    s:sel,    'NONE')
call s:hi('VisualNOS',    s:none,    s:sel,    'NONE')
call s:hi('MatchParen',   s:cyan,    s:sel,    'bold')
call s:hi('Search',       s:bg,      s:amber,  'NONE')
call s:hi('IncSearch',    s:bg,      s:cyan,   'bold')
call s:hi('CurSearch',    s:bg,      s:cyan,   'bold')
call s:hi('QuickFixLine', s:none,    s:sel,    'NONE')

" --- messages ----------------------------------------------------------------
call s:hi('ModeMsg',      s:cyan,    s:none,   'bold')
call s:hi('MoreMsg',      s:green,   s:none,   'NONE')
call s:hi('Question',     s:green,   s:none,   'NONE')
call s:hi('WarningMsg',   s:amber,   s:none,   'NONE')
call s:hi('ErrorMsg',     s:red,     s:none,   'bold')

" --- statusline and tabs -----------------------------------------------------
call s:hi('StatusLine',   s:bg,      s:cyan,   'bold')
call s:hi('StatusLineNC', s:fg,      s:bg_alt, 'NONE')
call s:hi('TabLine',      s:dim,     s:bg_alt, 'NONE')
call s:hi('TabLineFill',  s:none,    s:bg_alt, 'NONE')
call s:hi('TabLineSel',   s:cyan,    s:bg,     'bold')
call s:hi('WildMenu',     s:bg,      s:cyan,   'bold')

" --- popup menu --------------------------------------------------------------
call s:hi('Pmenu',        s:fg,      s:bg_alt, 'NONE')
call s:hi('PmenuSel',     s:bg,      s:cyan,   'bold')
call s:hi('PmenuSbar',    s:none,    s:bg_alt, 'NONE')
call s:hi('PmenuThumb',   s:none,    s:dim,    'NONE')

" --- diff --------------------------------------------------------------------
call s:hi('DiffAdd',      s:green,   s:add_bg, 'NONE')
call s:hi('DiffDelete',   s:red,     s:del_bg, 'NONE')
call s:hi('DiffChange',   s:none,    s:chg_bg, 'NONE')
call s:hi('DiffText',     s:amber,   s:chg_bg, 'bold')

" --- spelling ----------------------------------------------------------------
call s:hi('SpellBad',     s:none,    s:none,   'undercurl', s:red)
call s:hi('SpellCap',     s:none,    s:none,   'undercurl', s:amber)
call s:hi('SpellLocal',   s:none,    s:none,   'undercurl', s:cyan)
call s:hi('SpellRare',    s:none,    s:none,   'undercurl', s:magenta)

" --- syntax ------------------------------------------------------------------
call s:hi('Comment',        s:dim,     s:none, 'NONE')

call s:hi('Constant',       s:magenta, s:none, 'NONE')
call s:hi('String',         s:amber,   s:none, 'NONE')
call s:hi('Character',      s:amber,   s:none, 'NONE')
call s:hi('Number',         s:blue,    s:none, 'NONE')
call s:hi('Float',          s:blue,    s:none, 'NONE')
call s:hi('Boolean',        s:magenta, s:none, 'NONE')

call s:hi('Identifier',     s:cyan,    s:none, 'NONE')
call s:hi('Function',       s:green,   s:none, 'NONE')

call s:hi('Statement',      s:cyan,    s:none, 'NONE')
call s:hi('Conditional',    s:cyan,    s:none, 'NONE')
call s:hi('Repeat',         s:cyan,    s:none, 'NONE')
call s:hi('Label',          s:cyan,    s:none, 'NONE')
call s:hi('Keyword',        s:cyan,    s:none, 'NONE')
call s:hi('Exception',      s:cyan,    s:none, 'NONE')
call s:hi('Operator',       s:fg,      s:none, 'NONE')

call s:hi('PreProc',        s:magenta, s:none, 'NONE')
call s:hi('Include',        s:magenta, s:none, 'NONE')
call s:hi('Define',         s:magenta, s:none, 'NONE')
call s:hi('Macro',          s:magenta, s:none, 'NONE')
call s:hi('PreCondit',      s:magenta, s:none, 'NONE')

call s:hi('Type',           s:magenta, s:none, 'NONE')
call s:hi('StorageClass',   s:magenta, s:none, 'NONE')
call s:hi('Structure',      s:magenta, s:none, 'NONE')
call s:hi('Typedef',        s:magenta, s:none, 'NONE')

call s:hi('Special',        s:blue,    s:none, 'NONE')
call s:hi('SpecialChar',    s:blue,    s:none, 'NONE')
call s:hi('Tag',            s:cyan,    s:none, 'NONE')
call s:hi('Delimiter',      s:fg,      s:none, 'NONE')
call s:hi('SpecialComment', s:dim,     s:none, 'bold')
call s:hi('Debug',          s:amber,   s:none, 'NONE')

call s:hi('Underlined',     s:blue,    s:none, 'underline')
call s:hi('Ignore',         s:dim,     s:none, 'NONE')
call s:hi('Error',          s:red,     s:none, 'bold')
call s:hi('Todo',           s:amber,   s:bg_alt, 'bold')

" --- CRT state language ------------------------------------------------------
" Used by the statusline in vimrc. NORMAL cyan, INSERT amber, VISUAL magenta;
" REPLACE red (destructive) and COMMAND blue (informational) extend the same idea.
call s:hi('RetroModeNormal',  s:bg,  s:cyan,    'bold')
call s:hi('RetroModeInsert',  s:bg,  s:amber,   'bold')
call s:hi('RetroModeVisual',  s:bg,  s:magenta, 'bold')
call s:hi('RetroModeReplace', s:bg,  s:red,     'bold')
call s:hi('RetroModeCommand', s:bg,  s:blue,    'bold')
call s:hi('RetroModeTerminal',s:bg,  s:green,   'bold')
call s:hi('RetroStatusFile',  s:fg,  s:bg_alt,  'NONE')
call s:hi('RetroStatusInfo',  s:dim, s:bg_alt,  'NONE')

" --- netrw -------------------------------------------------------------------
" Filesystem roles, shared with Yazi and LS_COLORS:
" directory cyan, executable green, symlink magenta, marked amber.
call s:hi('netrwDir',      s:cyan,    s:none, 'NONE')
call s:hi('netrwClassify', s:dim,     s:none, 'NONE')
call s:hi('netrwTreeBar',  s:dim,     s:none, 'NONE')
call s:hi('netrwExe',      s:green,   s:none, 'NONE')
call s:hi('netrwSymLink',  s:magenta, s:none, 'NONE')
call s:hi('netrwMarkFile', s:bg,      s:amber,'bold')
call s:hi('netrwPlain',    s:fg,      s:none, 'NONE')
call s:hi('netrwVersion',  s:dim,     s:none, 'NONE')

" --- diff / git filetypes ----------------------------------------------------
call s:hi('diffAdded',    s:green,   s:none, 'NONE')
call s:hi('diffRemoved',  s:red,     s:none, 'NONE')
call s:hi('diffChanged',  s:amber,   s:none, 'NONE')
call s:hi('diffNewFile',  s:green,   s:none, 'NONE')
call s:hi('diffOldFile',  s:red,     s:none, 'NONE')
call s:hi('diffFile',     s:cyan,    s:none, 'bold')
call s:hi('diffLine',     s:blue,    s:none, 'NONE')
call s:hi('diffIndexLine',s:dim,     s:none, 'NONE')

call s:hi('gitcommitSummary',       s:fg,    s:none, 'NONE')
call s:hi('gitcommitComment',       s:dim,   s:none, 'NONE')
call s:hi('gitcommitBranch',        s:cyan,  s:none, 'bold')
call s:hi('gitcommitSelectedFile',  s:green, s:none, 'NONE')
call s:hi('gitcommitDiscardedFile', s:red,   s:none, 'NONE')
call s:hi('gitcommitUntrackedFile', s:amber, s:none, 'NONE')
call s:hi('gitcommitOverflow',      s:red,   s:none, 'NONE')

" --- :terminal ---------------------------------------------------------------
" Same ANSI mapping as the Ghostty adapter, for Vim's built-in terminal.
let g:terminal_ansi_colors = [
      \ '#0a0e14', '#e05050', '#40c070', '#ffb020',
      \ '#4080c0', '#e040a0', '#00d4c8', '#c8d0d8',
      \ '#5a6570', '#f07070', '#60d890', '#ffc850',
      \ '#60a0e0', '#f060c0', '#40ece0', '#e8f0f8',
      \ ]
