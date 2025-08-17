-- mini.surround configuration
-- Provides add/delete/change surrounding characters (quotes, brackets, tags)

local M = {}

-- Safely setup mini.surround if available
local function setup()
  local ok, mini_surround = pcall(require, 'mini.surround')
  if not ok then
    vim.notify('mini.surround not available - mini.nvim temporarily disabled due to installation issues', vim.log.levels.WARN)
    return
  end

  mini_surround.setup({
    -- Number of lines within which surrounding is searched
    n_lines = 20,
    -- Duration (in ms) of highlighting when adding/changing surrounding
    duration = 500,
    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
      add = 'sa', -- Add surrounding in Normal and Visual modes
      delete = 'sd', -- Delete surrounding
      find = 'sf', -- Find surrounding (to the right)
      find_left = 'sF', -- Find surrounding (to the left)
      highlight = 'sh', -- Highlight surrounding
      replace = 'sr', -- Replace surrounding
      update_n_lines = 'sn', -- Update `n_lines`
    },
    -- Custom surrounding patterns
    custom_surroundings = nil,
    -- Silently disable if no surrounding found
    respect_selection_type = true,
  })

  -- Which-key labels for surround operations
  local wk = require('which-key')
  wk.add({
    { '<leader>s', group = 'Surround' },
    { 'sa', desc = 'Surround: add', mode = { 'n', 'v' } },
    { 'sd', desc = 'Surround: delete' },
    { 'sf', desc = 'Surround: find right' },
    { 'sF', desc = 'Surround: find left' },
    { 'sh', desc = 'Surround: highlight' },
    { 'sr', desc = 'Surround: replace' },
    { 'sn', desc = 'Surround: update lines' },
  })
end

-- Setup when module is loaded
setup()

return M