-- motyw + statusline CRT (wersja mostowa)

vim.cmd("colorscheme retrocrt")

local function mode_label()
  local m = vim.fn.mode()
  local map = {
    n = " NORMAL ",
    i = " INSERT ",
    v = " VISUAL ",
    V = " VISUAL ",
    ["\22"] = " VISUAL ",
    R = " REPLACE ",
    c = " CMD ",
  }
  return map[m] or (" " .. m .. " ")
end

local function mode_color()
  local m = vim.fn.mode()
  if m == "i" then
    vim.api.nvim_set_hl(0, "RetroMode", { fg = "#0a0e14", bg = "#ffb020", bold = true })
  elseif m == "v" or m == "V" or m == "\22" then
    vim.api.nvim_set_hl(0, "RetroMode", { fg = "#0a0e14", bg = "#e040a0", bold = true })
  elseif m == "R" then
    vim.api.nvim_set_hl(0, "RetroMode", { fg = "#0a0e14", bg = "#e05050", bold = true })
  else
    vim.api.nvim_set_hl(0, "RetroMode", { fg = "#0a0e14", bg = "#00d4c8", bold = true })
  end
end

vim.api.nvim_set_hl(0, "RetroSep", { fg = "#00d4c8", bg = "#121820" })
vim.api.nvim_set_hl(0, "RetroInfo", { fg = "#c8d0d8", bg = "#121820" })
vim.api.nvim_set_hl(0, "RetroDim", { fg = "#5a6570", bg = "#121820" })
vim.api.nvim_set_hl(0, "RetroRight", { fg = "#0a0e14", bg = "#00d4c8", bold = true })

-- statusline woła funkcję globalną (najprostszy pewny sposób)
function _G.RetroNvimMode()
  mode_color()
  return mode_label()
end

vim.opt.statusline = table.concat({
  "%#RetroMode#%{v:lua.RetroNvimMode()}",
  "%#RetroSep# │ ",
  "%#RetroInfo#%f",
  "%#RetroDim# %m%r",
  "%#RetroSep# │ ",
  "%#RetroDim#%y",
  "%#RetroSep# │ ",
  "%#RetroDim#%{&fileencoding!=''?&fileencoding:&encoding}",
  "%=",
  "%#RetroSep# │ ",
  "%#RetroInfo#%p%% %l:%c ",
  "%#RetroRight# NVIM ",
})

vim.api.nvim_create_autocmd({ "ModeChanged", "VimEnter", "ColorScheme" }, {
  callback = function()
    vim.cmd("redrawstatus")
  end,
})
