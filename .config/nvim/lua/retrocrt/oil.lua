local M = {}

function M.setup()
  local ok, oil = pcall(require, "oil")
  if not ok then
    return false
  end

  oil.setup({
    default_file_explorer = true,
    columns = {
      "icon",
      "permissions",
      "size",
      "mtime",
    },
    delete_to_trash = false,
    skip_confirm_for_simple_edits = false,
    prompt_save_on_select_new_entry = true,
    view_options = {
      show_hidden = false,
      natural_order = true,
      is_always_hidden = function(name)
        return name == ".."
      end,
    },
    float = {
      border = "single",
    },
  })

  return true
end

return M
