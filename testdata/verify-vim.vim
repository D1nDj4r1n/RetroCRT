if get(g:, 'colors_name', '') !=# 'retrocrt' | cquit 2 | endif
if synIDattr(hlID('Normal'), 'bg#') !=# '#0a0e14' | cquit 3 | endif
if synIDattr(hlID('Directory'), 'fg#') !=# '#00d4c8' | cquit 4 | endif
if synIDattr(hlID('String'), 'fg#') !=# '#ffb020' | cquit 5 | endif
if synIDattr(hlID('Comment'), 'fg#') !=# '#5a6570' | cquit 6 | endif
if synIDattr(hlID('Function'), 'fg#') !=# '#40c070' | cquit 7 | endif
if synIDattr(hlID('Visual'), 'bg#') !=# '#1e3a4c' | cquit 8 | endif
if synIDattr(hlID('LineNr'), 'fg#') !=# '#5a6570' | cquit 9 | endif
if synIDattr(hlID('Search'), 'bg#') !=# '#ffb020' | cquit 10 | endif
if synIDattr(hlID('DiffAdd'), 'bg#') !=# '#122018' | cquit 11 | endif
if synIDattr(hlID('Pmenu'), 'bg#') !=# '#121820' | cquit 12 | endif
if synIDattr(hlID('Constant'), 'fg#') !=# '#e040a0' | cquit 13 | endif
qa
