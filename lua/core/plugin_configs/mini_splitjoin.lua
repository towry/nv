-- mini.splitjoin configuration
-- Provides toggle between single-line and multi-line code constructs

local M = {}

-- Safely setup mini.splitjoin if available
local function setup()
  local ok, mini_splitjoin = pcall(require, 'mini.splitjoin')
  if not ok then
    vim.notify('mini.splitjoin not available - mini.nvim temporarily disabled due to installation issues', vim.log.levels.WARN)
    return
  end

  mini_splitjoin.setup({
    -- Mappings
    mappings = {
      -- Toggle split/join in normal and visual mode
      toggle = 'gS',
    },
    -- Pre/post hooks for customization
    pre_split = nil,
    post_split = nil,
    pre_join = nil,
    post_join = nil,
    -- Filetype-specific configurations
    hooks = {
      -- Example: customize for specific filetypes if needed
      -- lua = { ... },
    },
  })

  -- Which-key labels for splitjoin
  local wk = require('which-key')
  wk.add({
    { 'gS', desc = 'Split/Join: toggle', mode = { 'n', 'v' } },
  })
end

-- Setup when module is loaded
setup()

return M