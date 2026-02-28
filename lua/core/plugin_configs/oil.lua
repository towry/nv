-- Oil.nvim configuration: file explorer that renders filesystem as a buffer
local M = {}

-- Safe require with error handling
local ok, oil = pcall(require, 'oil')
if not ok then
  vim.notify('oil.nvim not available', vim.log.levels.WARN)
  return M
end

-- Setup Oil with minimal defaults
oil.setup({
  default_file_explorer = true,
  columns = { 'icon' },
  view_options = {
    show_hidden = false,
  },
  delete_to_trash = false,
  skip_confirm_for_simple_edits = false,
  use_default_keymaps = true,
})

-- Toggle function for Oil
local function toggle_oil()
  if vim.bo.filetype == 'oil' then
    oil.close()
  else
    -- Open in current buffer directory, fallback to cwd
    local dir = vim.fn.expand('%:p:h')
    if dir == '' then
      dir = vim.fn.getcwd()
    end
    oil.open(dir)
  end
end

-- Global keymap for toggling Oil
vim.keymap.set('n', '<leader>e', toggle_oil, {
  noremap = true,
  silent = true,
  desc = 'Toggle Oil file explorer',
})

-- Register with which-key if available
pcall(function()
  local wk = require('which-key')
  wk.add({
    { '<leader>e', group = 'Explorer (Oil)' },
    { '<leader>e', toggle_oil, desc = 'Explorer (Oil): Toggle' },
  })
end)

-- Register with legendary if available
require('utils.legendary').register({
  itemgroups = {
    {
      itemgroup = 'Oil',
      icon = ' ',
      description = 'Oil file explorer',
      keymaps = {
        { '<leader>e', toggle_oil, description = 'Oil: Toggle' },
      },
    },
  }
})

return M