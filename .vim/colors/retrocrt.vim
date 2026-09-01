" retrocrt - restrained CRT workstation colors
set background=dark
hi clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'retrocrt'

let s:palette_file = expand('~/.config/retrocrt/palette')
if !filereadable(s:palette_file)
  echoerr 'retrocrt: canonical palette not found: ' . s:palette_file
  finish
endif

let s:p = {}
for s:line in readfile(s:palette_file)
  if s:line =~# '^[A-Z][A-Z_]*=#[0-9a-fA-F]\{6}$'
    let [s:key, s:value] = split(s:line, '=', 1)
    let s:p[s:key] = s:value
  endif
endfor

function! s:hi(group, foreground, background, ...) abort
  let l:command = 'highlight ' . a:group
  if !empty(a:foreground)
    let l:command .= ' guifg=' . a:foreground
  endif
  if !empty(a:background)
    let l:command .= ' guibg=' . a:background
  endif
  if a:0 && !empty(a:1)
    let l:command .= ' gui=' . a:1 . ' cterm=' . a:1
  else
    let l:command .= ' gui=NONE cterm=NONE'
  endif
  execute l:command
endfunction

call s:hi('Normal', s:p.FOREGROUND, s:p.BACKGROUND)
call s:hi('NormalNC', s:p.FOREGROUND, s:p.BACKGROUND)
call s:hi('EndOfBuffer', s:p.BACKGROUND, s:p.BACKGROUND)
call s:hi('NonText', s:p.DIM, s:p.BACKGROUND)
call s:hi('Whitespace', s:p.DIM, s:p.BACKGROUND)
call s:hi('SpecialKey', s:p.BLUE, s:p.BACKGROUND)

call s:hi('Cursor', s:p.BACKGROUND, s:p.FOREGROUND)
call s:hi('CursorLine', '', s:p.BACKGROUND_ALT)
call s:hi('CursorColumn', '', s:p.BACKGROUND_ALT)
call s:hi('ColorColumn', '', s:p.BACKGROUND_ALT)
call s:hi('LineNr', s:p.DIM, s:p.BACKGROUND)
call s:hi('CursorLineNr', s:p.AMBER, s:p.BACKGROUND_ALT, 'bold')
call s:hi('SignColumn', s:p.DIM, s:p.BACKGROUND)
call s:hi('FoldColumn', s:p.DIM, s:p.BACKGROUND)
call s:hi('Folded', s:p.DIM, s:p.BACKGROUND_ALT)

call s:hi('Visual', s:p.FOREGROUND, s:p.VISUAL_BG)
call s:hi('VisualNOS', s:p.FOREGROUND, s:p.VISUAL_BG)
call s:hi('Search', s:p.BACKGROUND, s:p.AMBER)
call s:hi('IncSearch', s:p.BACKGROUND, s:p.CYAN, 'bold')
call s:hi('CurSearch', s:p.BACKGROUND, s:p.CYAN, 'bold')
call s:hi('MatchParen', s:p.CYAN, s:p.VISUAL_BG, 'bold')

call s:hi('StatusLine', s:p.FOREGROUND, s:p.BACKGROUND_ALT)
call s:hi('StatusLineNC', s:p.DIM, s:p.BACKGROUND_ALT)
call s:hi('RetroStatusNormal', s:p.BACKGROUND, s:p.CYAN, 'bold')
call s:hi('RetroStatusInsert', s:p.BACKGROUND, s:p.AMBER, 'bold')
call s:hi('RetroStatusVisual', s:p.BACKGROUND, s:p.MAGENTA, 'bold')
call s:hi('VertSplit', s:p.DIM, s:p.BACKGROUND)
call s:hi('WinSeparator', s:p.DIM, s:p.BACKGROUND)
call s:hi('TabLine', s:p.DIM, s:p.BACKGROUND_ALT)
call s:hi('TabLineFill', s:p.DIM, s:p.BACKGROUND_ALT)
call s:hi('TabLineSel', s:p.CYAN, s:p.BACKGROUND, 'bold')
call s:hi('Title', s:p.CYAN, s:p.BACKGROUND, 'bold')

call s:hi('Pmenu', s:p.FOREGROUND, s:p.BACKGROUND_ALT)
call s:hi('PmenuSel', s:p.BACKGROUND, s:p.CYAN, 'bold')
call s:hi('PmenuSbar', '', s:p.BACKGROUND_ALT)
call s:hi('PmenuThumb', '', s:p.DIM)
call s:hi('WildMenu', s:p.BACKGROUND, s:p.CYAN)
call s:hi('Question', s:p.GREEN, s:p.BACKGROUND)
call s:hi('MoreMsg', s:p.CYAN, s:p.BACKGROUND)
call s:hi('ModeMsg', s:p.AMBER, s:p.BACKGROUND, 'bold')
call s:hi('WarningMsg', s:p.AMBER, s:p.BACKGROUND)
call s:hi('ErrorMsg', s:p.RED, s:p.BACKGROUND, 'bold')

call s:hi('Comment', s:p.DIM, '', 'italic')
call s:hi('Constant', s:p.MAGENTA, '')
call s:hi('String', s:p.AMBER, '')
call s:hi('Character', s:p.AMBER, '')
call s:hi('Number', s:p.BLUE, '')
call s:hi('Boolean', s:p.MAGENTA, '')
call s:hi('Float', s:p.BLUE, '')
call s:hi('Identifier', s:p.CYAN, '')
call s:hi('Function', s:p.GREEN, '')
call s:hi('Statement', s:p.CYAN, '')
call s:hi('Conditional', s:p.CYAN, '')
call s:hi('Repeat', s:p.CYAN, '')
call s:hi('Label', s:p.CYAN, '')
call s:hi('Operator', s:p.FOREGROUND, '')
call s:hi('Keyword', s:p.CYAN, '')
call s:hi('Exception', s:p.RED, '')
call s:hi('PreProc', s:p.MAGENTA, '')
call s:hi('Type', s:p.MAGENTA, '')
call s:hi('StorageClass', s:p.MAGENTA, '')
call s:hi('Structure', s:p.MAGENTA, '')
call s:hi('Typedef', s:p.MAGENTA, '')
call s:hi('Special', s:p.AMBER, '')
call s:hi('Underlined', s:p.BLUE, '', 'underline')
call s:hi('Ignore', s:p.DIM, '')
call s:hi('Error', s:p.RED, '', 'bold')
call s:hi('Todo', s:p.BACKGROUND, s:p.AMBER, 'bold')
call s:hi('Directory', s:p.CYAN, '', 'bold')

call s:hi('DiffAdd', s:p.GREEN, s:p.DIFF_ADD_BG)
call s:hi('DiffDelete', s:p.RED, s:p.DIFF_DELETE_BG)
call s:hi('DiffChange', s:p.AMBER, s:p.DIFF_CHANGE_BG)
call s:hi('DiffText', s:p.BACKGROUND, s:p.AMBER, 'bold')

call s:hi('SpellBad', s:p.RED, '', 'undercurl')
call s:hi('SpellCap', s:p.BLUE, '', 'undercurl')
call s:hi('SpellRare', s:p.MAGENTA, '', 'undercurl')
call s:hi('SpellLocal', s:p.CYAN, '', 'undercurl')

let g:terminal_ansi_colors = [
      \ s:p.BACKGROUND, s:p.RED, s:p.GREEN, s:p.AMBER,
      \ s:p.BLUE, s:p.MAGENTA, s:p.CYAN, s:p.FOREGROUND,
      \ s:p.DIM, s:p.BRIGHT_RED, s:p.BRIGHT_GREEN, s:p.BRIGHT_AMBER,
      \ s:p.BRIGHT_BLUE, s:p.BRIGHT_MAGENTA, s:p.BRIGHT_CYAN,
      \ s:p.BRIGHT_FOREGROUND
      \ ]

delfunction s:hi
unlet s:line s:key s:value
