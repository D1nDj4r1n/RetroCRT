-- retrocrt — Neovim adapter
-- Canonical palette: this table must match ../../palette
-- Vim remains the lightweight editor. Neovim is the IDE.
-- oil.nvim is the in-editor explorer (Yazi stays the terminal file manager).

local M = {}

M.palette = {
  BACKGROUND = "#0a0e14",
  BACKGROUND_ALT = "#121820",
  FOREGROUND = "#c8d0d8",
  DIM = "#5a6570",
  CYAN = "#00d4c8",
  AMBER = "#ffb020",
  MAGENTA = "#e040a0",
  GREEN = "#40c070",
  RED = "#e05050",
  BLUE = "#4080c0",
  VISUAL_BG = "#1e3a4c",
  DIFF_ADD_BG = "#122018",
  DIFF_DELETE_BG = "#201212",
  DIFF_CHANGE_BG = "#201a10",
}

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local function status_mode()
  local p = M.palette
  local first = vim.fn.mode(1):sub(1, 1)
  local bg = p.CYAN
  if first == "i" then
    bg = p.AMBER
  elseif first == "v" or first == "V" or first == "\22" or first == "s" or first == "S" or first == "\19" then
    bg = p.MAGENTA
  elseif first == "R" then
    bg = p.RED
  elseif first == "c" then
    bg = p.AMBER
  end
  hi("StatusLine", { fg = p.BACKGROUND, bg = bg })
  hi("ModeMsg", { fg = bg })
end

function M.apply()
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.g.colors_name = "retrocrt"

  local p = M.palette

  hi("Normal", { fg = p.FOREGROUND, bg = p.BACKGROUND })
  hi("NormalNC", { fg = p.FOREGROUND, bg = p.BACKGROUND })
  hi("NormalFloat", { fg = p.FOREGROUND, bg = p.BACKGROUND_ALT })
  hi("FloatBorder", { fg = p.DIM, bg = p.BACKGROUND_ALT })
  hi("FloatTitle", { fg = p.CYAN, bg = p.BACKGROUND_ALT })
  hi("EndOfBuffer", { fg = p.BACKGROUND, bg = p.BACKGROUND })
  hi("NonText", { fg = p.DIM })
  hi("SpecialKey", { fg = p.DIM })
  hi("Whitespace", { fg = p.DIM })
  hi("Conceal", { fg = p.DIM })

  hi("Cursor", { fg = p.BACKGROUND, bg = p.CYAN })
  hi("lCursor", { fg = p.BACKGROUND, bg = p.CYAN })
  hi("TermCursor", { fg = p.BACKGROUND, bg = p.CYAN })
  hi("CursorLine", { bg = p.BACKGROUND_ALT })
  hi("CursorColumn", { bg = p.BACKGROUND_ALT })
  hi("ColorColumn", { bg = p.BACKGROUND_ALT })
  hi("CursorLineNr", { fg = p.AMBER, bg = p.BACKGROUND_ALT })
  hi("LineNr", { fg = p.DIM })
  hi("SignColumn", { fg = p.DIM, bg = p.BACKGROUND })
  hi("FoldColumn", { fg = p.DIM, bg = p.BACKGROUND })
  hi("Folded", { fg = p.DIM, bg = p.BACKGROUND_ALT })

  hi("Visual", { bg = p.VISUAL_BG })
  hi("VisualNOS", { bg = p.VISUAL_BG })
  hi("MatchParen", { fg = p.CYAN, bg = p.VISUAL_BG })

  hi("Search", { fg = p.BACKGROUND, bg = p.AMBER })
  hi("IncSearch", { fg = p.BACKGROUND, bg = p.CYAN })
  hi("CurSearch", { fg = p.BACKGROUND, bg = p.CYAN })
  hi("Substitute", { fg = p.BACKGROUND, bg = p.AMBER })

  hi("StatusLine", { fg = p.BACKGROUND, bg = p.CYAN })
  hi("StatusLineNC", { fg = p.DIM, bg = p.BACKGROUND_ALT })
  hi("WinSeparator", { fg = p.DIM, bg = p.BACKGROUND })
  hi("VertSplit", { fg = p.DIM, bg = p.BACKGROUND })
  hi("TabLine", { fg = p.DIM, bg = p.BACKGROUND_ALT })
  hi("TabLineFill", { fg = p.DIM, bg = p.BACKGROUND })
  hi("TabLineSel", { fg = p.BACKGROUND, bg = p.CYAN })
  hi("WinBar", { fg = p.CYAN, bg = p.BACKGROUND_ALT })
  hi("WinBarNC", { fg = p.DIM, bg = p.BACKGROUND_ALT })
  hi("QuickFixLine", { bg = p.VISUAL_BG })

  hi("Pmenu", { fg = p.FOREGROUND, bg = p.BACKGROUND_ALT })
  hi("PmenuSel", { fg = p.BACKGROUND, bg = p.CYAN })
  hi("PmenuSbar", { bg = p.BACKGROUND_ALT })
  hi("PmenuThumb", { bg = p.DIM })
  hi("PmenuKind", { fg = p.BLUE, bg = p.BACKGROUND_ALT })
  hi("PmenuExtra", { fg = p.DIM, bg = p.BACKGROUND_ALT })
  hi("WildMenu", { fg = p.BACKGROUND, bg = p.CYAN })

  hi("Title", { fg = p.CYAN })
  hi("Directory", { fg = p.CYAN })
  hi("Question", { fg = p.GREEN })
  hi("MoreMsg", { fg = p.GREEN })
  hi("ModeMsg", { fg = p.CYAN })
  hi("ErrorMsg", { fg = p.RED })
  hi("WarningMsg", { fg = p.AMBER })
  hi("Error", { fg = p.RED })
  hi("Todo", { fg = p.AMBER, bg = p.BACKGROUND_ALT })
  hi("Underlined", { fg = p.BLUE, underline = true })
  hi("Ignore", { fg = p.DIM })

  hi("DiffAdd", { fg = p.GREEN, bg = p.DIFF_ADD_BG })
  hi("DiffChange", { fg = p.AMBER, bg = p.DIFF_CHANGE_BG })
  hi("DiffDelete", { fg = p.RED, bg = p.DIFF_DELETE_BG })
  hi("DiffText", { fg = p.AMBER, bg = p.VISUAL_BG })
  hi("Added", { fg = p.GREEN })
  hi("Changed", { fg = p.AMBER })
  hi("Removed", { fg = p.RED })

  hi("SpellBad", { fg = p.RED, undercurl = true })
  hi("SpellCap", { fg = p.BLUE, undercurl = true })
  hi("SpellRare", { fg = p.MAGENTA, undercurl = true })
  hi("SpellLocal", { fg = p.CYAN, undercurl = true })

  hi("Comment", { fg = p.DIM, italic = true })
  hi("SpecialComment", { fg = p.DIM, italic = true })
  hi("Constant", { fg = p.MAGENTA })
  hi("String", { fg = p.AMBER })
  hi("Character", { fg = p.AMBER })
  hi("Number", { fg = p.BLUE })
  hi("Boolean", { fg = p.MAGENTA })
  hi("Float", { fg = p.BLUE })
  hi("Identifier", { fg = p.CYAN })
  hi("Function", { fg = p.GREEN })
  hi("Statement", { fg = p.CYAN })
  hi("Conditional", { fg = p.CYAN })
  hi("Repeat", { fg = p.CYAN })
  hi("Label", { fg = p.CYAN })
  hi("Operator", { fg = p.FOREGROUND })
  hi("Keyword", { fg = p.CYAN })
  hi("Exception", { fg = p.RED })
  hi("PreProc", { fg = p.MAGENTA })
  hi("Include", { fg = p.MAGENTA })
  hi("Define", { fg = p.MAGENTA })
  hi("Macro", { fg = p.MAGENTA })
  hi("PreCondit", { fg = p.MAGENTA })
  hi("Type", { fg = p.MAGENTA })
  hi("StorageClass", { fg = p.MAGENTA })
  hi("Structure", { fg = p.MAGENTA })
  hi("Typedef", { fg = p.MAGENTA })
  hi("Special", { fg = p.AMBER })
  hi("SpecialChar", { fg = p.AMBER })
  hi("Tag", { fg = p.CYAN })
  hi("Delimiter", { fg = p.FOREGROUND })
  hi("Debug", { fg = p.RED })

  -- Diagnostics (LSP). Do not install LSP here; only color the groups.
  hi("DiagnosticError", { fg = p.RED })
  hi("DiagnosticWarn", { fg = p.AMBER })
  hi("DiagnosticInfo", { fg = p.BLUE })
  hi("DiagnosticHint", { fg = p.CYAN })
  hi("DiagnosticOk", { fg = p.GREEN })
  hi("DiagnosticUnnecessary", { fg = p.DIM })
  hi("DiagnosticUnderlineError", { sp = p.RED, undercurl = true })
  hi("DiagnosticUnderlineWarn", { sp = p.AMBER, undercurl = true })
  hi("DiagnosticUnderlineInfo", { sp = p.BLUE, undercurl = true })
  hi("DiagnosticUnderlineHint", { sp = p.CYAN, undercurl = true })
  hi("DiagnosticVirtualTextError", { fg = p.RED, bg = p.DIFF_DELETE_BG })
  hi("DiagnosticVirtualTextWarn", { fg = p.AMBER, bg = p.DIFF_CHANGE_BG })
  hi("DiagnosticVirtualTextInfo", { fg = p.BLUE, bg = p.BACKGROUND_ALT })
  hi("DiagnosticVirtualTextHint", { fg = p.CYAN, bg = p.BACKGROUND_ALT })
  hi("LspReferenceText", { bg = p.VISUAL_BG })
  hi("LspReferenceRead", { bg = p.VISUAL_BG })
  hi("LspReferenceWrite", { bg = p.VISUAL_BG })
  hi("LspInlayHint", { fg = p.DIM })
  hi("LspSignatureActiveParameter", { fg = p.AMBER })

  -- Treesitter links (no extra hues)
  local ts = {
    ["@comment"] = "Comment",
    ["@string"] = "String",
    ["@character"] = "Character",
    ["@number"] = "Number",
    ["@boolean"] = "Boolean",
    ["@float"] = "Float",
    ["@constant"] = "Constant",
    ["@constant.builtin"] = "Constant",
    ["@function"] = "Function",
    ["@function.builtin"] = "Function",
    ["@method"] = "Function",
    ["@variable"] = "Identifier",
    ["@variable.builtin"] = "Identifier",
    ["@property"] = "Identifier",
    ["@field"] = "Identifier",
    ["@parameter"] = "Identifier",
    ["@keyword"] = "Keyword",
    ["@keyword.function"] = "Keyword",
    ["@keyword.return"] = "Keyword",
    ["@conditional"] = "Conditional",
    ["@repeat"] = "Repeat",
    ["@type"] = "Type",
    ["@type.builtin"] = "Type",
    ["@namespace"] = "Type",
    ["@include"] = "Include",
    ["@preproc"] = "PreProc",
    ["@punctuation"] = "Delimiter",
    ["@punctuation.bracket"] = "Delimiter",
    ["@punctuation.delimiter"] = "Delimiter",
    ["@operator"] = "Operator",
    ["@tag"] = "Tag",
    ["@text.title"] = "Title",
    ["@markup.heading"] = "Title",
    ["@markup.raw"] = "String",
    ["@markup.link"] = "Underlined",
  }
  for group, link in pairs(ts) do
    hi(group, { link = link })
  end

  -- oil.nvim — file explorer inside Neovim. Not a Yazi replacement.
  hi("OilDir", { fg = p.CYAN })
  hi("OilDirIcon", { fg = p.CYAN })
  hi("OilDirHidden", { fg = p.DIM })
  hi("OilFile", { fg = p.FOREGROUND })
  hi("OilFileHidden", { fg = p.DIM })
  hi("OilHidden", { fg = p.DIM })
  hi("OilLink", { fg = p.BLUE })
  hi("OilLinkHidden", { fg = p.DIM })
  hi("OilOrphanLink", { fg = p.RED })
  hi("OilOrphanLinkHidden", { fg = p.RED })
  hi("OilLinkTarget", { fg = p.BLUE })
  hi("OilOrphanLinkTarget", { fg = p.RED })
  hi("OilSocket", { fg = p.MAGENTA })
  hi("OilCreate", { fg = p.GREEN })
  hi("OilDelete", { fg = p.RED })
  hi("OilMove", { fg = p.AMBER })
  hi("OilCopy", { fg = p.CYAN })
  hi("OilChange", { fg = p.AMBER })
  hi("OilRestore", { fg = p.GREEN })
  hi("OilPurge", { fg = p.RED })
  hi("OilTrash", { fg = p.RED })
  hi("OilTrashSourcePath", { fg = p.DIM })
  hi("OilEmpty", { fg = p.DIM })

  hi("User1", { fg = p.BACKGROUND, bg = p.CYAN })
  hi("User2", { fg = p.BACKGROUND, bg = p.AMBER })
  hi("User3", { fg = p.BACKGROUND, bg = p.MAGENTA })
  hi("User4", { fg = p.BACKGROUND, bg = p.RED })

  status_mode()

  local aug = vim.api.nvim_create_augroup("retrocrt_status", { clear = true })
  vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "ModeChanged" }, {
    group = aug,
    callback = status_mode,
  })
end

return M
