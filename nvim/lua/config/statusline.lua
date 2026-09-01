-- Statusline in the CRT state language: NORMAL cyan, INSERT amber,
-- VISUAL magenta, REPLACE red, COMMAND blue, TERMINAL green.
-- Highlight groups come from the retrocrt colorscheme.

local M = {}

local modes = {
  n = { 'NORMAL', 'RetroModeNormal' },
  no = { 'PENDING', 'RetroModeNormal' },
  v = { 'VISUAL', 'RetroModeVisual' },
  V = { 'V-LINE', 'RetroModeVisual' },
  ['\22'] = { 'V-BLOCK', 'RetroModeVisual' },
  s = { 'SELECT', 'RetroModeVisual' },
  S = { 'S-LINE', 'RetroModeVisual' },
  ['\19'] = { 'S-BLOCK', 'RetroModeVisual' },
  i = { 'INSERT', 'RetroModeInsert' },
  ic = { 'INSERT', 'RetroModeInsert' },
  R = { 'REPLACE', 'RetroModeReplace' },
  Rv = { 'V-REPLACE', 'RetroModeReplace' },
  c = { 'COMMAND', 'RetroModeCommand' },
  cv = { 'EX', 'RetroModeCommand' },
  r = { 'PROMPT', 'RetroModeCommand' },
  rm = { 'MORE', 'RetroModeCommand' },
  ['r?'] = { 'CONFIRM', 'RetroModeCommand' },
  ['!'] = { 'SHELL', 'RetroModeTerminal' },
  t = { 'TERMINAL', 'RetroModeTerminal' },
}

local function diagnostics()
  local out = {}
  for _, level in ipairs({
    { 'ERROR', 'E', 'DiagnosticError' },
    { 'WARN', 'W', 'DiagnosticWarn' },
    { 'INFO', 'I', 'DiagnosticInfo' },
    { 'HINT', 'H', 'DiagnosticHint' },
  }) do
    local n = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[level[1]] })
    if n > 0 then
      table.insert(out, ('%%#%s#%s%d'):format(level[3], level[2], n))
    end
  end
  return #out > 0 and (table.concat(out, ' ') .. ' ') or ''
end

function M.render()
  local mode = modes[vim.api.nvim_get_mode().mode] or { 'NORMAL', 'RetroModeNormal' }
  local ft = vim.bo.filetype
  return table.concat({
    '%#', mode[2], '# ', mode[1], ' ',
    -- %< marks where to truncate. Without it the default is the start of the
    -- line, so a long path would eat the mode indicator first.
    '%#RetroStatusFile# %<%f%m%r',
    '%#RetroStatusInfo#%= ',
    diagnostics(),
    '%#RetroStatusInfo#',
    ft ~= '' and ft or 'none', '  ',
    '%{&fileencoding == "" ? &encoding : &fileencoding}  %{&fileformat} ',
    '%#', mode[2], '# %l:%c  %p%% ',
  })
end

vim.o.statusline = "%!v:lua.require'config.statusline'.render()"

return M
