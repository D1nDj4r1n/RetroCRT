local M = {}

local packages = {
  {
    name = "oil.nvim",
    url = "https://github.com/stevearc/oil.nvim.git",
  },
}

local root = vim.fn.stdpath("config") .. "/pack/retro/start"

local function run(command)
  local output = vim.fn.system(command)
  if vim.v.shell_error ~= 0 then
    error(table.concat(command, " ") .. "\n" .. output)
  end
  return output
end

function M.ensure()
  vim.fn.mkdir(root, "p")
  for _, package in ipairs(packages) do
    local destination = root .. "/" .. package.name
    if vim.fn.isdirectory(destination .. "/.git") == 0 then
      vim.notify("Installing " .. package.name, vim.log.levels.INFO)
      run({ "git", "clone", "--filter=blob:none", package.url, destination })
    end
  end
  vim.cmd("packloadall")
  vim.notify("pack/retro is present", vim.log.levels.INFO)
end

function M.update()
  for _, package in ipairs(packages) do
    local destination = root .. "/" .. package.name
    if vim.fn.isdirectory(destination .. "/.git") == 1 then
      vim.notify("Updating " .. package.name, vim.log.levels.INFO)
      run({ "git", "-C", destination, "pull", "--ff-only" })
    else
      vim.notify(package.name .. " is missing; run :PackEnsure", vim.log.levels.WARN)
    end
  end
  vim.notify("pack/retro update complete", vim.log.levels.INFO)
end

function M.setup()
  vim.api.nvim_create_user_command("PackEnsure", function()
    local ok, err = pcall(M.ensure)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end, { desc = "Install missing pack/retro plugins" })

  vim.api.nvim_create_user_command("PackUpdate", function()
    local ok, err = pcall(M.update)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end, { desc = "Fast-forward installed pack/retro plugins" })
end

return M
