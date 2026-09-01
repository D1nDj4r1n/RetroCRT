redir! > /tmp/vim-hi.txt
echo 'colors_name=' . g:colors_name
hi Normal
hi Comment
hi String
hi Character
hi Number
hi Constant
hi Identifier
hi Function
hi Statement
hi Type
hi Directory
hi LineNr
hi CursorLine
hi CursorLineNr
hi Visual
hi Search
hi StatusLine
hi StatusLineNC
hi Pmenu
hi PmenuSel
hi DiffAdd
hi DiffDelete
hi DiffChange
hi MatchParen
redir END
qa
