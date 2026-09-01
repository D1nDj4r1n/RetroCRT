local M = {}

function M.setup()
  local p = require("retrocrt.palette")
  local set = vim.api.nvim_set_hl

  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = "retrocrt"

  local groups = {
    Normal = { fg = p.FOREGROUND, bg = p.BACKGROUND },
    NormalNC = { fg = p.FOREGROUND, bg = p.BACKGROUND },
    NormalFloat = { fg = p.FOREGROUND, bg = p.BACKGROUND_ALT },
    FloatBorder = { fg = p.DIM, bg = p.BACKGROUND_ALT },
    FloatTitle = { fg = p.CYAN, bg = p.BACKGROUND_ALT, bold = true },
    EndOfBuffer = { fg = p.BACKGROUND, bg = p.BACKGROUND },
    NonText = { fg = p.DIM },
    Whitespace = { fg = p.DIM },
    SpecialKey = { fg = p.BLUE },

    Cursor = { fg = p.BACKGROUND, bg = p.FOREGROUND },
    CursorLine = { bg = p.BACKGROUND_ALT },
    CursorColumn = { bg = p.BACKGROUND_ALT },
    ColorColumn = { bg = p.BACKGROUND_ALT },
    LineNr = { fg = p.DIM },
    CursorLineNr = { fg = p.AMBER, bg = p.BACKGROUND_ALT, bold = true },
    SignColumn = { fg = p.DIM, bg = p.BACKGROUND },
    FoldColumn = { fg = p.DIM, bg = p.BACKGROUND },
    Folded = { fg = p.DIM, bg = p.BACKGROUND_ALT },

    Visual = { fg = p.FOREGROUND, bg = p.VISUAL },
    VisualNOS = { fg = p.FOREGROUND, bg = p.VISUAL },
    Search = { fg = p.BACKGROUND, bg = p.AMBER },
    IncSearch = { fg = p.BACKGROUND, bg = p.CYAN, bold = true },
    CurSearch = { fg = p.BACKGROUND, bg = p.CYAN, bold = true },
    Substitute = { fg = p.BACKGROUND, bg = p.MAGENTA },
    MatchParen = { fg = p.CYAN, bg = p.VISUAL, bold = true },

    StatusLine = { fg = p.FOREGROUND, bg = p.BACKGROUND_ALT },
    StatusLineNC = { fg = p.DIM, bg = p.BACKGROUND_ALT },
    RetroStatusNormal = { fg = p.BACKGROUND, bg = p.CYAN, bold = true },
    RetroStatusInsert = { fg = p.BACKGROUND, bg = p.AMBER, bold = true },
    RetroStatusVisual = { fg = p.BACKGROUND, bg = p.MAGENTA, bold = true },
    WinSeparator = { fg = p.DIM, bg = p.BACKGROUND },
    TabLine = { fg = p.DIM, bg = p.BACKGROUND_ALT },
    TabLineFill = { fg = p.DIM, bg = p.BACKGROUND_ALT },
    TabLineSel = { fg = p.CYAN, bg = p.BACKGROUND, bold = true },
    Title = { fg = p.CYAN, bold = true },

    Pmenu = { fg = p.FOREGROUND, bg = p.BACKGROUND_ALT },
    PmenuSel = { fg = p.BACKGROUND, bg = p.CYAN, bold = true },
    PmenuSbar = { bg = p.BACKGROUND_ALT },
    PmenuThumb = { bg = p.DIM },
    WildMenu = { fg = p.BACKGROUND, bg = p.CYAN },
    Question = { fg = p.GREEN },
    MoreMsg = { fg = p.CYAN },
    ModeMsg = { fg = p.AMBER, bold = true },
    WarningMsg = { fg = p.AMBER },
    ErrorMsg = { fg = p.RED, bold = true },

    Comment = { fg = p.DIM, italic = true },
    Constant = { fg = p.MAGENTA },
    String = { fg = p.AMBER },
    Character = { fg = p.AMBER },
    Number = { fg = p.BLUE },
    Boolean = { fg = p.MAGENTA },
    Float = { fg = p.BLUE },
    Identifier = { fg = p.CYAN },
    Function = { fg = p.GREEN },
    Statement = { fg = p.CYAN },
    Conditional = { fg = p.CYAN },
    Repeat = { fg = p.CYAN },
    Label = { fg = p.CYAN },
    Operator = { fg = p.FOREGROUND },
    Keyword = { fg = p.CYAN },
    Exception = { fg = p.RED },
    PreProc = { fg = p.MAGENTA },
    Type = { fg = p.MAGENTA },
    StorageClass = { fg = p.MAGENTA },
    Structure = { fg = p.MAGENTA },
    Typedef = { fg = p.MAGENTA },
    Special = { fg = p.AMBER },
    Underlined = { fg = p.BLUE, underline = true },
    Ignore = { fg = p.DIM },
    Error = { fg = p.RED, bold = true },
    Todo = { fg = p.BACKGROUND, bg = p.AMBER, bold = true },
    Directory = { fg = p.CYAN, bold = true },

    DiffAdd = { fg = p.GREEN, bg = p.DIFF_ADD_BG },
    DiffDelete = { fg = p.RED, bg = p.DIFF_DELETE_BG },
    DiffChange = { fg = p.AMBER, bg = p.DIFF_CHANGE_BG },
    DiffText = { fg = p.BACKGROUND, bg = p.AMBER, bold = true },
    Added = { fg = p.GREEN },
    Removed = { fg = p.RED },
    Changed = { fg = p.AMBER },

    DiagnosticError = { fg = p.RED },
    DiagnosticWarn = { fg = p.AMBER },
    DiagnosticInfo = { fg = p.BLUE },
    DiagnosticHint = { fg = p.CYAN },
    DiagnosticOk = { fg = p.GREEN },
    DiagnosticUnderlineError = { undercurl = true, sp = p.RED },
    DiagnosticUnderlineWarn = { undercurl = true, sp = p.AMBER },
    DiagnosticUnderlineInfo = { undercurl = true, sp = p.BLUE },
    DiagnosticUnderlineHint = { undercurl = true, sp = p.CYAN },

    GitSignsAdd = { fg = p.GREEN },
    GitSignsChange = { fg = p.AMBER },
    GitSignsDelete = { fg = p.RED },

    OilDir = { fg = p.CYAN, bold = true },
    OilDirIcon = { fg = p.CYAN },
    OilLink = { fg = p.BLUE },
    OilLinkTarget = { fg = p.DIM },
    OilFile = { fg = p.FOREGROUND },
    OilCreate = { fg = p.GREEN },
    OilDelete = { fg = p.RED },
    OilMove = { fg = p.AMBER },
    OilCopy = { fg = p.BLUE },
    OilChange = { fg = p.AMBER },
    OilPermissionRead = { fg = p.BLUE },
    OilPermissionWrite = { fg = p.AMBER },
    OilPermissionExecute = { fg = p.GREEN },
    OilPermissionNone = { fg = p.DIM },
  }

  for name, opts in pairs(groups) do
    set(0, name, opts)
  end

  local links = {
    ["@comment"] = "Comment",
    ["@constant"] = "Constant",
    ["@constant.builtin"] = "Constant",
    ["@string"] = "String",
    ["@character"] = "Character",
    ["@number"] = "Number",
    ["@boolean"] = "Boolean",
    ["@variable"] = "Identifier",
    ["@variable.builtin"] = "Special",
    ["@function"] = "Function",
    ["@function.builtin"] = "Function",
    ["@function.call"] = "Function",
    ["@constructor"] = "Type",
    ["@keyword"] = "Keyword",
    ["@keyword.return"] = "Keyword",
    ["@operator"] = "Operator",
    ["@type"] = "Type",
    ["@type.builtin"] = "Type",
    ["@property"] = "Identifier",
    ["@punctuation"] = "Delimiter",
    ["@markup.heading"] = "Title",
    ["@markup.link"] = "Underlined",
    ["@diff.plus"] = "Added",
    ["@diff.minus"] = "Removed",
    ["@diff.delta"] = "Changed",
    LspReferenceText = "Visual",
    LspReferenceRead = "Visual",
    LspReferenceWrite = "Visual",
  }

  for name, target in pairs(links) do
    set(0, name, { link = target })
  end

  for index, color in ipairs(p.ANSI) do
    vim.g["terminal_color_" .. (index - 1)] = color
  end
end

return M
