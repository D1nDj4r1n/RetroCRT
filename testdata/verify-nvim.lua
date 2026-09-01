local function must(group, key, want, code)
  local hl = vim.api.nvim_get_hl(0, { name = group })
  if hl[key] ~= want then
    io.stderr:write(string.format("%s.%s got %s want %s\n", group, key, tostring(hl[key]), tostring(want)))
    os.exit(code)
  end
end

if vim.g.colors_name ~= "retrocrt" then
  os.exit(2)
end

must("Normal", "bg", 0x0a0e14, 3)
must("OilDir", "fg", 0x00d4c8, 4)
must("DiagnosticError", "fg", 0xe05050, 5)
must("Search", "bg", 0xffb020, 6)
must("PmenuSel", "bg", 0x00d4c8, 7)
must("String", "fg", 0xffb020, 8)
must("Comment", "fg", 0x5a6570, 9)

vim.cmd("qa")
