-- MiniDiff configuration
local M = {}

local ok, diff = pcall(require, 'mini.diff')
if not ok then
  return M
end

-- Setup with view and delay configuration per design specification
-- See: https://nvim-mini.org/mini.nvim/doc/mini-diff.html
diff.setup({
  view = {
    style = vim.go.number and 'number' or 'sign',
    priority = 199,
  },
  source = nil, -- use default Git source
  delay = { text_change = 200 },
  mappings = {
    -- keep defaults: apply='gh', reset='gH', textobject='gh', goto_*='[h]/]h'/etc
  },
})

-- NOTE: Keymaps are global here for simplicity and availability across buffers.
-- They are safe in non-git buffers: MiniDiff functions will simply have no effect
-- if the module isn't enabled for the current buffer.

-- Navigation: keep parity with prior ]c / [c behavior with diff-window passthrough
vim.keymap.set('n', ']c', function()
  if vim.wo.diff then return ']c' end
  vim.schedule(function() diff.goto_hunk('next') end)
  return '<Ignore>'
end, { expr = true, desc = 'Next hunk (MiniDiff)' })

vim.keymap.set('n', '[c', function()
  if vim.wo.diff then return '[c' end
  vim.schedule(function() diff.goto_hunk('prev') end)
  return '<Ignore>'
end, { expr = true, desc = 'Previous hunk (MiniDiff)' })

-- Actions: apply (stage) / reset current line
local function current_line_bounds()
  local l = vim.api.nvim_win_get_cursor(0)[1]
  return l, l
end

vim.keymap.set('n', '<leader>ghs', function()
  local s, e = current_line_bounds()
  diff.do_hunks(0, 'apply', { line_start = s, line_end = e })
end, { desc = 'Apply hunk at line (MiniDiff)' })

vim.keymap.set('n', '<leader>ghr', function()
  local s, e = current_line_bounds()
  diff.do_hunks(0, 'reset', { line_start = s, line_end = e })
end, { desc = 'Reset hunk at line (MiniDiff)' })

-- Textobject: hunk range under cursor via 'ih'
vim.keymap.set({ 'o', 'x' }, 'ih', function()
  diff.textobject()
end, { desc = 'Hunk textobject (MiniDiff)' })

-- Overlay toggle
vim.keymap.set('n', '<leader>gO', function()
  diff.toggle_overlay(0)
end, { desc = 'Toggle diff overlay (MiniDiff)' })

return M