-- mini.snippets configuration
-- Provides snippet expansion and navigation

local M = {}

-- Safely setup mini.snippets if available
local function setup()
  local ok, mini_snippets = pcall(require, 'mini.snippets')
  if not ok then
    vim.notify('mini.snippets not available - mini.nvim temporarily disabled due to installation issues', vim.log.levels.WARN)
    return
  end

  mini_snippets.setup({
    -- Search paths for snippets
    search_paths = { vim.fn.stdpath('config') .. '/snippets' },
    -- Filetype-specific snippet directories
    filetype_paths = {},
    -- Visual selection handling
    visual_selection = {
      -- How to treat visual selection when expanding snippet
      mode = 'delete', -- 'delete', 'keep', 'indent'
    },
    -- Mappings
    mappings = {
      -- Insert mode mappings for snippet navigation
      insert = {
        -- Jump to next placeholder
        jump_next = '<C-j>',
        -- Jump to previous placeholder
        jump_prev = '<C-k>',
        -- Stop snippet editing
        stop = '<C-c>',
      },
      -- Normal mode mappings
      normal = {},
    },
  })

  -- Insert mode keymaps for snippet jumping
  vim.keymap.set('i', '<C-j>', function() return require('mini.snippets').jump(1) end, { expr = true, desc = 'Snippet: jump forward' })
  vim.keymap.set('i', '<C-k>', function() return require('mini.snippets').jump(-1) end, { expr = true, desc = 'Snippet: jump backward' })

  -- Ensure snippet navigation works in select mode as well
  vim.keymap.set('s', '<C-j>', function()
    return mini_snippets.jump(1)
  end, { desc = 'Snippet: jump forward' })

  vim.keymap.set('s', '<C-k>', function()
    return mini_snippets.jump(-1)
  end, { desc = 'Snippet: jump backward' })

  -- Which-key labels for snippet navigation
  local wk = require('which-key')
  wk.add({
    { '<C-j>', desc = 'Snippet: jump forward', mode = { 'i', 's' } },
    { '<C-k>', desc = 'Snippet: jump backward', mode = { 'i', 's' } },
  })
end

-- Setup when module is loaded
setup()

return M