-- mini.operators configuration
-- Provides text operators: exchange, replace, evaluate, sort, multiply

local M = {}

-- Safely setup mini.operators if available
local function setup()
  local ok, mini_operators = pcall(require, 'mini.operators')
  if not ok then
    vim.notify('mini.operators not available - mini.nvim temporarily disabled due to installation issues', vim.log.levels.WARN)
    return
  end

  mini_operators.setup({
    -- Exchange operator
    exchange = {
      prefix = 'gX',
      reindent_linewise = true,
    },
    -- Replace operator
    replace = {
      prefix = 'gR',
      reindent_linewise = true,
    },
    -- Evaluate operator
    evaluate = {
      prefix = 'g=',
    },
    -- Sort operator
    sort = {
      prefix = 'gs',
    },
    -- Multiply operator
    multiply = {
      prefix = 'gm',
    },
  })

  -- Which-key labels for operators
  local wk = require('which-key')
  wk.add({
    { '<leader>o', group = 'Operators' },
    { 'gX', desc = 'Operator: exchange', mode = { 'n', 'v' } },
    { 'gR', desc = 'Operator: replace', mode = { 'n', 'v' } },
    { 'g=', desc = 'Operator: evaluate', mode = { 'n', 'v' } },
    { 'gs', desc = 'Operator: sort', mode = { 'n', 'v' } },
    { 'gm', desc = 'Operator: multiply', mode = { 'n', 'v' } },
  })
end

-- Setup when module is loaded
setup()

return M