-- lib.pack — the whole plugin system.
--
-- Plugins are plain git checkouts under ~/.config/nvim/pack/retro/opt and are
-- loaded with :packadd, which is Neovim's own package mechanism. There is no
-- plugin manager, no lockfile and no startup hook: a plugin is a directory,
-- and loading one is a single command.
--
--   :PackEnsure   clone anything missing, then rebuild helptags
--   :PackUpdate   git pull every plugin
--   :PackStatus   list what is installed and what is not
--
-- `opt` rather than `start` is deliberate. Neovim adds `start` packages to
-- 'runtimepath' *after* init.lua has run, so configuration written there
-- cannot require them. With `opt` the load order is explicit and deterministic.

local M = {}

-- name -> git remote. The directory name is the key.
M.plugins = {
  ['oil.nvim'] = 'https://github.com/stevearc/oil.nvim.git',
}

M.dir = vim.fn.stdpath('config') .. '/pack/retro/opt'

local function path_of(name)
  return M.dir .. '/' .. name
end

local function installed(name)
  return vim.fn.isdirectory(path_of(name)) == 1
end

local function git(args)
  local out = vim.fn.system(vim.list_extend({ 'git' }, args))
  return vim.v.shell_error == 0, vim.trim(out)
end

local function helptags(name)
  local doc = path_of(name) .. '/doc'
  if vim.fn.isdirectory(doc) == 1 then
    pcall(vim.cmd, 'helptags ' .. vim.fn.fnameescape(doc))
  end
end

--- Clone any plugin that is not on disk yet.
function M.ensure()
  vim.fn.mkdir(M.dir, 'p')
  for name, url in pairs(M.plugins) do
    if installed(name) then
      vim.notify('pack: ' .. name .. ' present', vim.log.levels.INFO)
    else
      vim.notify('pack: cloning ' .. name, vim.log.levels.INFO)
      -- Blobless clone: full history for `git log`, without paying for old blobs.
      local ok, out = git({ 'clone', '--filter=blob:none', url, path_of(name) })
      if ok then
        helptags(name)
        vim.notify('pack: installed ' .. name, vim.log.levels.INFO)
      else
        vim.notify('pack: failed to clone ' .. name .. '\n' .. out, vim.log.levels.ERROR)
      end
    end
  end
end

--- Fast-forward every installed plugin.
function M.update()
  for name, _ in pairs(M.plugins) do
    if not installed(name) then
      vim.notify('pack: ' .. name .. ' not installed, run :PackEnsure', vim.log.levels.WARN)
    else
      local ok, out = git({ '-C', path_of(name), 'pull', '--ff-only' })
      if ok then
        helptags(name)
        vim.notify('pack: ' .. name .. ' ' .. out, vim.log.levels.INFO)
      else
        vim.notify('pack: update failed for ' .. name .. '\n' .. out, vim.log.levels.ERROR)
      end
    end
  end
end

function M.status()
  local lines = { 'pack/retro (' .. M.dir .. ')' }
  for name, url in pairs(M.plugins) do
    table.insert(lines, ('  %-14s %-10s %s'):format(name, installed(name) and 'installed' or 'MISSING', url))
  end
  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
end

--- packadd a plugin. Returns false instead of erroring when it is missing,
--- so a fresh checkout still starts and can run :PackEnsure.
function M.load(name)
  if not installed(name) then
    return false
  end
  local ok = pcall(vim.cmd.packadd, name)
  return ok
end

function M.setup()
  vim.api.nvim_create_user_command('PackEnsure', M.ensure, { desc = 'Clone missing pack/retro plugins' })
  vim.api.nvim_create_user_command('PackUpdate', M.update, { desc = 'Update pack/retro plugins' })
  vim.api.nvim_create_user_command('PackStatus', M.status, { desc = 'List pack/retro plugins' })
end

return M
