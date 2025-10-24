-- Legendary.nvim configuration
-- Keybind finder and management

local M = {}

pcall(function()
  local legendary = require('legendary')

  -- Set up legendary with fzf-lua UI provider
  legendary.setup({
    select_prompt = ' legendary.nvim ',
    include_builtin = true,
    include_legendary_cmds = true,
    include_auto_groups = false,

    extensions = {
      lazy_nvim = false,
      which_key = false,
      diffview = false,
    },

    icons = {
      keymap = ' ',
      command = ' ',
      fn = '󰡱 ',
      itemgroup = ' ',
    },

    sort = {
      most_recent_first = false,
      user_items_first = true,
      frecency = false,
    },

    default_opts = {
      keymaps = {
        silent = true,
        noremap = true,
      },
    },
  })

  local ok_fzf = pcall(require, 'fzf-lua')
  if ok_fzf then
    require('fzf-lua').register_ui_select()
  end
end)

return M
