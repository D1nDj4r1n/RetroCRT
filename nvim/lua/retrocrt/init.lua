-- retrocrt — Neovim adapter.
--
-- Same semantics as the Vim colorscheme, extended with the groups Vim does not
-- have: diagnostics, LSP, treesitter captures, floats and oil.nvim.
--
--   :colorscheme retrocrt

local p = require('retrocrt.palette')

local M = {}

local function hl(groups)
  for group, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

function M.load()
  vim.cmd('highlight clear')
  if vim.fn.exists('syntax_on') == 1 then
    vim.cmd('syntax reset')
  end

  vim.o.background = 'dark'
  vim.g.colors_name = 'retrocrt'

  hl({
    -- editor surfaces
    Normal = { fg = p.fg, bg = p.bg },
    NormalNC = { fg = p.fg, bg = p.bg },
    NormalFloat = { fg = p.fg, bg = p.bg_alt },
    FloatBorder = { fg = p.dim, bg = p.bg_alt },
    FloatTitle = { fg = p.cyan, bg = p.bg_alt, bold = true },
    NonText = { fg = p.dim },
    EndOfBuffer = { fg = p.dim },
    SpecialKey = { fg = p.dim },
    Whitespace = { fg = p.dim },
    Conceal = { fg = p.dim },
    ColorColumn = { bg = p.bg_alt },
    CursorColumn = { bg = p.bg_alt },
    CursorLine = { bg = p.bg_alt },
    Cursor = { fg = p.bg, bg = p.cyan },
    lCursor = { fg = p.bg, bg = p.cyan },
    TermCursor = { fg = p.bg, bg = p.cyan },
    LineNr = { fg = p.dim },
    CursorLineNr = { fg = p.amber, bg = p.bg_alt, bold = true },
    SignColumn = { fg = p.dim },
    FoldColumn = { fg = p.dim },
    Folded = { fg = p.dim, bg = p.bg_alt },
    WinSeparator = { fg = p.dim },
    VertSplit = { fg = p.dim },
    Directory = { fg = p.cyan },
    Title = { fg = p.cyan, bold = true },
    MsgArea = { fg = p.fg },
    MsgSeparator = { fg = p.dim, bg = p.bg_alt },
    WinBar = { fg = p.fg, bg = p.bg_alt },
    WinBarNC = { fg = p.dim, bg = p.bg_alt },

    -- selection and search
    Visual = { bg = p.sel },
    VisualNOS = { bg = p.sel },
    MatchParen = { fg = p.cyan, bg = p.sel, bold = true },
    Search = { fg = p.bg, bg = p.amber },
    IncSearch = { fg = p.bg, bg = p.cyan, bold = true },
    CurSearch = { fg = p.bg, bg = p.cyan, bold = true },
    Substitute = { fg = p.bg, bg = p.amber },
    QuickFixLine = { bg = p.sel },

    -- messages
    ModeMsg = { fg = p.cyan, bold = true },
    MoreMsg = { fg = p.green },
    Question = { fg = p.green },
    WarningMsg = { fg = p.amber },
    ErrorMsg = { fg = p.red, bold = true },

    -- statusline and tabs
    StatusLine = { fg = p.bg, bg = p.cyan, bold = true },
    StatusLineNC = { fg = p.fg, bg = p.bg_alt },
    TabLine = { fg = p.dim, bg = p.bg_alt },
    TabLineFill = { bg = p.bg_alt },
    TabLineSel = { fg = p.cyan, bg = p.bg, bold = true },
    WildMenu = { fg = p.bg, bg = p.cyan, bold = true },

    -- popup menu
    Pmenu = { fg = p.fg, bg = p.bg_alt },
    PmenuSel = { fg = p.bg, bg = p.cyan, bold = true },
    PmenuSbar = { bg = p.bg_alt },
    PmenuThumb = { bg = p.dim },
    PmenuKind = { fg = p.magenta, bg = p.bg_alt },
    PmenuKindSel = { fg = p.bg, bg = p.cyan, bold = true },
    PmenuExtra = { fg = p.dim, bg = p.bg_alt },
    PmenuExtraSel = { fg = p.bg, bg = p.cyan },

    -- diff
    DiffAdd = { fg = p.green, bg = p.add_bg },
    DiffDelete = { fg = p.red, bg = p.del_bg },
    DiffChange = { bg = p.chg_bg },
    DiffText = { fg = p.amber, bg = p.chg_bg, bold = true },

    -- spelling
    SpellBad = { undercurl = true, sp = p.red },
    SpellCap = { undercurl = true, sp = p.amber },
    SpellLocal = { undercurl = true, sp = p.cyan },
    SpellRare = { undercurl = true, sp = p.magenta },

    -- syntax
    Comment = { fg = p.dim },
    Constant = { fg = p.magenta },
    String = { fg = p.amber },
    Character = { fg = p.amber },
    Number = { fg = p.blue },
    Float = { fg = p.blue },
    Boolean = { fg = p.magenta },
    Identifier = { fg = p.cyan },
    Function = { fg = p.green },
    Statement = { fg = p.cyan },
    Conditional = { fg = p.cyan },
    Repeat = { fg = p.cyan },
    Label = { fg = p.cyan },
    Keyword = { fg = p.cyan },
    Exception = { fg = p.cyan },
    Operator = { fg = p.fg },
    PreProc = { fg = p.magenta },
    Include = { fg = p.magenta },
    Define = { fg = p.magenta },
    Macro = { fg = p.magenta },
    PreCondit = { fg = p.magenta },
    Type = { fg = p.magenta },
    StorageClass = { fg = p.magenta },
    Structure = { fg = p.magenta },
    Typedef = { fg = p.magenta },
    Special = { fg = p.blue },
    SpecialChar = { fg = p.blue },
    Tag = { fg = p.cyan },
    Delimiter = { fg = p.fg },
    SpecialComment = { fg = p.dim, bold = true },
    Debug = { fg = p.amber },
    Underlined = { fg = p.blue, underline = true },
    Ignore = { fg = p.dim },
    Error = { fg = p.red, bold = true },
    Todo = { fg = p.amber, bg = p.bg_alt, bold = true },
    Added = { fg = p.green },
    Removed = { fg = p.red },
    Changed = { fg = p.amber },

    -- diagnostics
    DiagnosticError = { fg = p.red },
    DiagnosticWarn = { fg = p.amber },
    DiagnosticInfo = { fg = p.blue },
    DiagnosticHint = { fg = p.cyan },
    DiagnosticOk = { fg = p.green },
    DiagnosticUnderlineError = { undercurl = true, sp = p.red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = p.amber },
    DiagnosticUnderlineInfo = { undercurl = true, sp = p.blue },
    DiagnosticUnderlineHint = { undercurl = true, sp = p.cyan },
    DiagnosticUnderlineOk = { undercurl = true, sp = p.green },
    DiagnosticVirtualTextError = { fg = p.red, bg = p.bg_alt },
    DiagnosticVirtualTextWarn = { fg = p.amber, bg = p.bg_alt },
    DiagnosticVirtualTextInfo = { fg = p.blue, bg = p.bg_alt },
    DiagnosticVirtualTextHint = { fg = p.cyan, bg = p.bg_alt },
    DiagnosticVirtualTextOk = { fg = p.green, bg = p.bg_alt },

    -- LSP
    LspReferenceText = { bg = p.sel },
    LspReferenceRead = { bg = p.sel },
    LspReferenceWrite = { bg = p.sel, underline = true },
    LspSignatureActiveParameter = { fg = p.amber, bold = true },
    LspInlayHint = { fg = p.dim, bg = p.bg_alt },
    LspCodeLens = { fg = p.dim },

    -- CRT state language, used by the statusline
    RetroModeNormal = { fg = p.bg, bg = p.cyan, bold = true },
    RetroModeInsert = { fg = p.bg, bg = p.amber, bold = true },
    RetroModeVisual = { fg = p.bg, bg = p.magenta, bold = true },
    RetroModeReplace = { fg = p.bg, bg = p.red, bold = true },
    RetroModeCommand = { fg = p.bg, bg = p.blue, bold = true },
    RetroModeTerminal = { fg = p.bg, bg = p.green, bold = true },
    RetroStatusFile = { fg = p.fg, bg = p.bg_alt },
    RetroStatusInfo = { fg = p.dim, bg = p.bg_alt },

    -- oil.nvim: the same filesystem roles as netrw, Yazi and LS_COLORS.
    OilDir = { fg = p.cyan },
    OilDirIcon = { fg = p.cyan },
    OilFile = { fg = p.fg },
    OilLink = { fg = p.magenta },
    OilLinkTarget = { fg = p.dim },
    OilSocket = { fg = p.magenta },
    OilSize = { fg = p.blue },
    OilMtime = { fg = p.dim },
    OilTypeDir = { fg = p.cyan },
    OilTypeFile = { fg = p.fg },
    OilTypeLink = { fg = p.magenta },
    OilTypeSocket = { fg = p.magenta },
    OilTypeFifo = { fg = p.magenta },
    OilPermissionNone = { fg = p.dim },
    OilPermissionRead = { fg = p.amber },
    OilPermissionWrite = { fg = p.red },
    OilPermissionExecute = { fg = p.green },
    OilCreate = { fg = p.green },
    OilCopy = { fg = p.blue },
    OilMove = { fg = p.amber },
    OilChange = { fg = p.amber },
    OilDelete = { fg = p.red },
    OilPurge = { fg = p.red, bold = true },
    OilTrash = { fg = p.red },
    OilTrashSourcePath = { fg = p.dim },
    OilRestore = { fg = p.green },
  })

  -- Treesitter captures. Neovim already links most of them to the classic
  -- groups above, so only the ones whose default would be too loud are set.
  -- @variable covers nearly every word in a buffer; leaving it on Identifier
  -- would paint whole files cyan, which contradicts the restraint rule.
  hl({
    ['@variable'] = { fg = p.fg },
    ['@variable.member'] = { fg = p.fg },
    ['@property'] = { fg = p.fg },
    ['@field'] = { fg = p.fg },
    ['@variable.parameter'] = { fg = p.blue },
    ['@variable.builtin'] = { fg = p.magenta },
    ['@constant'] = { fg = p.magenta },
    ['@constant.builtin'] = { fg = p.magenta },
    ['@module'] = { fg = p.cyan },
    ['@constructor'] = { fg = p.magenta },
    ['@punctuation.delimiter'] = { fg = p.fg },
    ['@punctuation.bracket'] = { fg = p.fg },
    ['@punctuation.special'] = { fg = p.blue },
    ['@comment.error'] = { fg = p.red, bold = true },
    ['@comment.warning'] = { fg = p.amber, bold = true },
    ['@comment.todo'] = { fg = p.amber, bg = p.bg_alt, bold = true },
    ['@comment.note'] = { fg = p.cyan, bold = true },
    ['@diff.plus'] = { fg = p.green },
    ['@diff.minus'] = { fg = p.red },
    ['@diff.delta'] = { fg = p.amber },
    ['@markup.heading'] = { fg = p.cyan, bold = true },
    ['@markup.link'] = { fg = p.blue, underline = true },
    ['@markup.link.url'] = { fg = p.dim },
    ['@markup.raw'] = { fg = p.amber },
    ['@markup.list'] = { fg = p.cyan },
    ['@markup.strong'] = { bold = true },
  })

  -- :terminal — same ANSI mapping as the Ghostty adapter.
  local ansi = {
    p.bg, p.red, p.green, p.amber,
    p.blue, p.magenta, p.cyan, p.fg,
    p.dim, p.bright_red, p.bright_green, p.bright_amber,
    p.bright_blue, p.bright_magenta, p.bright_cyan, p.bright_white,
  }
  for i, colour in ipairs(ansi) do
    vim.g['terminal_color_' .. (i - 1)] = colour
  end
end

return M
