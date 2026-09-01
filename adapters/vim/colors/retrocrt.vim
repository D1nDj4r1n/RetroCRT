" retrocrt — Vim adapter
" Canonical palette: ../../../../palette  (install: ~/.config/retrocrt/palette)
" This file is an adapter. Change HEX values in `palette` first, then here.
"
" Role: lightweight editor. Not the IDE.
" CRT status: NORMAL=CYAN  INSERT=AMBER  VISUAL=MAGENTA  REPLACE=RED

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "retrocrt"

if has("termguicolors")
  set termguicolors
endif

" Canonical
let s:bg      = "#0a0e14"
let s:bg_alt  = "#121820"
let s:fg      = "#c8d0d8"
let s:dim     = "#5a6570"
let s:cyan    = "#00d4c8"
let s:amber   = "#ffb020"
let s:magenta = "#e040a0"
let s:green   = "#40c070"
let s:red     = "#e05050"
let s:blue    = "#4080c0"

" Derived
let s:visual  = "#1e3a4c"
let s:diff_a  = "#122018"
let s:diff_d  = "#201212"
let s:diff_c  = "#201a10"

function! s:h(group, fg, bg, gui, ctermfg, ctermbg, cterm)
  let l:cmd = "hi " . a:group
  if a:fg !=# ""
    let l:cmd .= " guifg=" . a:fg
  else
    let l:cmd .= " guifg=NONE"
  endif
  if a:bg !=# ""
    let l:cmd .= " guibg=" . a:bg
  else
    let l:cmd .= " guibg=NONE"
  endif
  let l:cmd .= " gui=" . (a:gui ==# "" ? "NONE" : a:gui)
  if a:ctermfg !=# ""
    let l:cmd .= " ctermfg=" . a:ctermfg
  else
    let l:cmd .= " ctermfg=NONE"
  endif
  if a:ctermbg !=# ""
    let l:cmd .= " ctermbg=" . a:ctermbg
  else
    let l:cmd .= " ctermbg=NONE"
  endif
  let l:cmd .= " cterm=" . (a:cterm ==# "" ? "NONE" : a:cterm)
  execute l:cmd
endfunction

" --- UI -------------------------------------------------------------------
call s:h("Normal",       s:fg, s:bg,     "", "7", "0", "")
call s:h("NormalNC",     s:fg, s:bg,     "", "7", "0", "")
call s:h("EndOfBuffer",  s:bg, s:bg,     "", "0", "0", "")
call s:h("NonText",      s:dim, "",      "", "8", "", "")
call s:h("SpecialKey",   s:dim, "",      "", "8", "", "")
call s:h("Whitespace",   s:dim, "",      "", "8", "", "")
call s:h("Conceal",      s:dim, "",      "", "8", "", "")

call s:h("Cursor",       s:bg, s:cyan,   "", "0", "6", "")
call s:h("lCursor",      s:bg, s:cyan,   "", "0", "6", "")
call s:h("CursorIM",     s:bg, s:cyan,   "", "0", "6", "")
call s:h("TermCursor",   s:bg, s:cyan,   "", "0", "6", "")
call s:h("CursorLine",   "", s:bg_alt,   "", "", "0", "")
call s:h("CursorColumn", "", s:bg_alt,   "", "", "0", "")
call s:h("ColorColumn",  "", s:bg_alt,   "", "", "8", "")
call s:h("CursorLineNr", s:amber, s:bg_alt, "NONE", "3", "0", "")
call s:h("LineNr",       s:dim, "",      "", "8", "", "")
call s:h("LineNrAbove",  s:dim, "",      "", "8", "", "")
call s:h("LineNrBelow",  s:dim, "",      "", "8", "", "")
call s:h("SignColumn",   s:dim, s:bg,    "", "8", "0", "")
call s:h("FoldColumn",   s:dim, s:bg,    "", "8", "0", "")
call s:h("Folded",       s:dim, s:bg_alt, "", "8", "0", "")

call s:h("Visual",       "", s:visual,   "", "", "4", "")
call s:h("VisualNOS",    "", s:visual,   "", "", "4", "")
call s:h("MatchParen",   s:cyan, s:visual, "NONE", "6", "4", "")

call s:h("Search",       s:bg, s:amber,  "", "0", "3", "")
call s:h("IncSearch",    s:bg, s:cyan,   "", "0", "6", "")
call s:h("CurSearch",    s:bg, s:cyan,   "", "0", "6", "")
call s:h("Substitute",   s:bg, s:amber,  "", "0", "3", "")

call s:h("StatusLine",   s:bg, s:cyan,   "NONE", "0", "6", "")
call s:h("StatusLineNC", s:dim, s:bg_alt, "NONE", "8", "0", "")
call s:h("StatusLineTerm", s:bg, s:cyan, "NONE", "0", "6", "")
call s:h("StatusLineTermNC", s:dim, s:bg_alt, "NONE", "8", "0", "")
call s:h("WinSeparator", s:dim, s:bg,    "", "8", "0", "")
call s:h("VertSplit",    s:dim, s:bg,    "", "8", "0", "")
call s:h("TabLine",      s:dim, s:bg_alt, "NONE", "8", "0", "")
call s:h("TabLineFill",  s:dim, s:bg,     "NONE", "8", "0", "")
call s:h("TabLineSel",   s:bg, s:cyan,    "NONE", "0", "6", "")
call s:h("QuickFixLine", "", s:visual,   "", "", "4", "")
call s:h("WinBar",       s:cyan, s:bg_alt, "NONE", "6", "0", "")
call s:h("WinBarNC",     s:dim, s:bg_alt, "NONE", "8", "0", "")

call s:h("Pmenu",        s:fg, s:bg_alt, "", "7", "0", "")
call s:h("PmenuSel",     s:bg, s:cyan,   "", "0", "6", "")
call s:h("PmenuSbar",    "", s:bg_alt,   "", "", "0", "")
call s:h("PmenuThumb",   "", s:dim,      "", "", "8", "")
call s:h("PmenuKind",    s:blue, s:bg_alt, "", "4", "0", "")
call s:h("PmenuExtra",   s:dim, s:bg_alt, "", "8", "0", "")
call s:h("WildMenu",     s:bg, s:cyan,   "", "0", "6", "")

call s:h("Title",        s:cyan, "",     "", "6", "", "")
call s:h("Directory",    s:cyan, "",     "", "6", "", "")
call s:h("Question",     s:green, "",    "", "2", "", "")
call s:h("MoreMsg",      s:green, "",    "", "2", "", "")
call s:h("ModeMsg",      s:cyan, "",     "NONE", "6", "", "")
call s:h("ErrorMsg",     s:red, "",      "", "1", "", "")
call s:h("WarningMsg",   s:amber, "",    "", "3", "", "")
call s:h("MsgArea",      s:fg, s:bg,     "", "7", "0", "")
call s:h("MsgSeparator", s:dim, s:bg_alt, "", "8", "0", "")

call s:h("Error",        s:red, "",      "", "1", "", "")
call s:h("Todo",         s:amber, s:bg_alt, "", "3", "0", "")
call s:h("Underlined",   s:blue, "",     "underline", "4", "", "underline")
call s:h("Ignore",       s:dim, "",      "", "8", "", "")

" Diff
call s:h("DiffAdd",      s:green, s:diff_a, "", "2", "0", "")
call s:h("DiffChange",   s:amber, s:diff_c, "", "3", "0", "")
call s:h("DiffDelete",   s:red, s:diff_d,   "", "1", "0", "")
call s:h("DiffText",     s:amber, s:visual, "", "3", "4", "")
call s:h("Added",        s:green, "",       "", "2", "", "")
call s:h("Changed",      s:amber, "",       "", "3", "", "")
call s:h("Removed",      s:red, "",         "", "1", "", "")

" Spell
call s:h("SpellBad",     s:red, "",      "undercurl", "1", "", "underline")
call s:h("SpellCap",     s:blue, "",     "undercurl", "4", "", "underline")
call s:h("SpellRare",    s:magenta, "",  "undercurl", "5", "", "underline")
call s:h("SpellLocal",   s:cyan, "",     "undercurl", "6", "", "underline")

" --- Syntax ---------------------------------------------------------------
call s:h("Comment",      s:dim, "",      "italic", "8", "", "")
call s:h("SpecialComment", s:dim, "",    "italic", "8", "", "")

call s:h("Constant",     s:magenta, "",  "", "5", "", "")
call s:h("String",       s:amber, "",    "", "3", "", "")
call s:h("Character",    s:amber, "",    "", "3", "", "")
call s:h("Number",       s:blue, "",     "", "4", "", "")
call s:h("Boolean",      s:magenta, "",  "", "5", "", "")
call s:h("Float",        s:blue, "",     "", "4", "", "")

call s:h("Identifier",   s:cyan, "",     "", "6", "", "")
call s:h("Function",     s:green, "",    "", "2", "", "")

call s:h("Statement",    s:cyan, "",     "", "6", "", "")
call s:h("Conditional",  s:cyan, "",     "", "6", "", "")
call s:h("Repeat",       s:cyan, "",     "", "6", "", "")
call s:h("Label",        s:cyan, "",     "", "6", "", "")
call s:h("Operator",     s:fg, "",       "", "7", "", "")
call s:h("Keyword",      s:cyan, "",     "", "6", "", "")
call s:h("Exception",    s:red, "",      "", "1", "", "")

call s:h("PreProc",      s:magenta, "",  "", "5", "", "")
call s:h("Include",      s:magenta, "",  "", "5", "", "")
call s:h("Define",       s:magenta, "",  "", "5", "", "")
call s:h("Macro",        s:magenta, "",  "", "5", "", "")
call s:h("PreCondit",    s:magenta, "",  "", "5", "", "")

call s:h("Type",         s:magenta, "",  "", "5", "", "")
call s:h("StorageClass", s:magenta, "",  "", "5", "", "")
call s:h("Structure",    s:magenta, "",  "", "5", "", "")
call s:h("Typedef",      s:magenta, "",  "", "5", "", "")

call s:h("Special",      s:amber, "",    "", "3", "", "")
call s:h("SpecialChar",  s:amber, "",    "", "3", "", "")
call s:h("Tag",          s:cyan, "",     "", "6", "", "")
call s:h("Delimiter",    s:fg, "",       "", "7", "", "")
call s:h("Debug",        s:red, "",      "", "1", "", "")

" netrw
hi! link netrwDir Directory
hi! link netrwClassify Directory
hi! link netrwLink Identifier
hi! link netrwSymLink Identifier
hi! link netrwExe Function
hi! link netrwPlain Normal
hi! link netrwTreebar WinSeparator

" User highlights for optional statusline: %1* NORMAL  %2* INSERT  %3* VISUAL
call s:h("User1", s:bg, s:cyan,    "NONE", "0", "6", "")
call s:h("User2", s:bg, s:amber,   "NONE", "0", "3", "")
call s:h("User3", s:bg, s:magenta, "NONE", "0", "5", "")
call s:h("User4", s:bg, s:red,     "NONE", "0", "1", "")

" CRT status language on StatusLine (mode colors). Does not replace a custom statusline.
function! s:RetrocrtStatusMode()
  let l:m = mode(1)
  if l:m =~# '^i'
    hi StatusLine guifg=#0a0e14 guibg=#ffb020 ctermfg=0 ctermbg=3 gui=NONE cterm=NONE
    hi ModeMsg guifg=#ffb020 guibg=NONE ctermfg=3 ctermbg=NONE gui=NONE cterm=NONE
  elseif l:m =~# '^[vV\x16sS\x13]'
    hi StatusLine guifg=#0a0e14 guibg=#e040a0 ctermfg=0 ctermbg=5 gui=NONE cterm=NONE
    hi ModeMsg guifg=#e040a0 guibg=NONE ctermfg=5 ctermbg=NONE gui=NONE cterm=NONE
  elseif l:m =~# '^R'
    hi StatusLine guifg=#0a0e14 guibg=#e05050 ctermfg=0 ctermbg=1 gui=NONE cterm=NONE
    hi ModeMsg guifg=#e05050 guibg=NONE ctermfg=1 ctermbg=NONE gui=NONE cterm=NONE
  elseif l:m =~# '^c'
    hi StatusLine guifg=#0a0e14 guibg=#ffb020 ctermfg=0 ctermbg=3 gui=NONE cterm=NONE
    hi ModeMsg guifg=#ffb020 guibg=NONE ctermfg=3 ctermbg=NONE gui=NONE cterm=NONE
  else
    hi StatusLine guifg=#0a0e14 guibg=#00d4c8 ctermfg=0 ctermbg=6 gui=NONE cterm=NONE
    hi ModeMsg guifg=#00d4c8 guibg=NONE ctermfg=6 ctermbg=NONE gui=NONE cterm=NONE
  endif
endfunction

augroup retrocrt_status
  autocmd!
  autocmd VimEnter,WinEnter,ModeChanged * call s:RetrocrtStatusMode()
augroup END
