local M = {}

local required = {
  "BACKGROUND",
  "BACKGROUND_ALT",
  "FOREGROUND",
  "DIM",
  "CYAN",
  "AMBER",
  "MAGENTA",
  "GREEN",
  "RED",
  "BLUE",
  "VISUAL_BG",
  "DIFF_ADD_BG",
  "DIFF_DELETE_BG",
  "DIFF_CHANGE_BG",
  "BRIGHT_RED",
  "BRIGHT_GREEN",
  "BRIGHT_AMBER",
  "BRIGHT_BLUE",
  "BRIGHT_MAGENTA",
  "BRIGHT_CYAN",
  "BRIGHT_FOREGROUND",
}

local path = vim.fn.expand("~/.config/retrocrt/palette")
local file, open_error = io.open(path, "r")
if not file then
  error(("retrocrt: cannot read canonical palette %s: %s"):format(path, open_error))
end

for line in file:lines() do
  local name, value = line:match("^([A-Z][A-Z_]*)=(#[0-9a-fA-F]+)$")
  if name and #value == 7 then
    M[name] = value:lower()
  end
end
file:close()

for _, name in ipairs(required) do
  if not M[name] then
    error(("retrocrt: canonical palette is missing %s"):format(name))
  end
end

M.ANSI = {
  M.BACKGROUND,
  M.RED,
  M.GREEN,
  M.AMBER,
  M.BLUE,
  M.MAGENTA,
  M.CYAN,
  M.FOREGROUND,
  M.DIM,
  M.BRIGHT_RED,
  M.BRIGHT_GREEN,
  M.BRIGHT_AMBER,
  M.BRIGHT_BLUE,
  M.BRIGHT_MAGENTA,
  M.BRIGHT_CYAN,
  M.BRIGHT_FOREGROUND,
}

return M
