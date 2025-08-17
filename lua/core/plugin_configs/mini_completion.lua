-- mini.completion configuration
-- Provides LSP completion with manual trigger and confirm/abort mappings

local M = {}

-- Safely setup mini.completion if available
local function setup()
  local ok, mini_completion = pcall(require, 'mini.completion')
  if not ok then
    vim.notify('mini.completion not available - mini.nvim temporarily disabled due to installation issues', vim.log.levels.WARN)
    return
  end

  mini_completion.setup({
    -- Delay in milliseconds before showing completion
    delay = { completion = 100, info = 100, signature = 50 },
    -- Maximum number of items to show
    max_items = 20,
    -- Window configuration
    window = {
      info = { height = 25, width = 80, border = 'single' },
      signature = { height = 25, width = 80, border = 'single' },
    },
    -- LSP source configuration
    lsp_completion = {
      source_func = 'omnifunc',
      auto_setup = false,
      process_items = function(items, base)
        return items
      end,
    },
    -- Mapping configuration
    mappings = {
      -- Force completion update
      force_fallback = '<C-Space>',
      -- Scroll documentation
      scroll_down = '<C-d>',
      scroll_up = '<C-u>',
      -- Complete with text from current line
      complete_with_line = '<C-l>',
    },
    -- Filetypes to exclude from completion
    filetype_exclude = {
      'TelescopePrompt',
      'fzf',
      'OverseerForm',
    },
  })

  -- Additional mappings for confirm/abort
  vim.keymap.set('i', '<CR>', function()
    if vim.fn.pumvisible() == 1 then
      return '<C-y>' -- Confirm completion
    else
      return '<CR>'
    end
  end, { expr = true, desc = 'Completion: confirm' })

  vim.keymap.set('i', '<C-e>', function()
    if vim.fn.pumvisible() == 1 then
      return '<C-e>' -- Abort completion
    else
      return '<C-e>'
    end
  end, { expr = true, desc = 'Completion: abort' })

  -- Fallback trigger if <C-Space> is intercepted by OS/terminal
  vim.keymap.set('i', '<C-n>', function()
    return '<C-Space>'
  end, { expr = true, desc = 'Completion: trigger (fallback)' })

  -- Which-key labels for completion commands
  local wk = require('which-key')
  wk.add({
    { '<C-Space>', desc = 'Completion: trigger', mode = 'i' },
    { '<C-e>', desc = 'Completion: abort', mode = 'i' },
    { '<CR>', desc = 'Completion: confirm', mode = 'i' },
    { '<C-n>', desc = 'Completion: trigger (fallback)', mode = 'i' },
  })
end

-- Setup when module is loaded
setup()

return M