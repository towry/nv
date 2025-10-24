-- Fugitive configuration
local M = {}

-- Fugitive setup
vim.g.fugitive_git_command = 'git'

local function get_visual_range()
  local start = vim.fn.line("'<")
  local finish = vim.fn.line("'>")
  if start == 0 then start = 1 end
  if finish == 0 then finish = vim.fn.line('$') end
  return { start = start, finish = finish }
end

-- Setup fugitive keymaps with descriptions (which-key will pick these up automatically)
vim.keymap.set('n', '<leader>gs', '<cmd>Git<cr>', { desc = 'Git status' })
vim.keymap.set('n', '<leader>gb', '<cmd>Git blame<cr>', { desc = 'Git blame' })
vim.keymap.set('n', '<leader>gd', '<cmd>Gdiffsplit<cr>', { desc = 'Git diff split' })

-- Git log utilities
vim.keymap.set('n', '<leader>gl', function()
  local count = vim.v.count
  local max_count_arg = count > 0 and string.format('--max-count=%d', count) or '--max-count=30'
  vim.cmd(
    'vert Git log -P '
    .. max_count_arg
    .. ' --oneline --date=format:"%Y-%m-%d %H:%M" --pretty=format:"%h %ad: %s - %an" -- %'
  )
end, { desc = 'Git log for current file' })

vim.keymap.set('x', '<leader>gl', function()
  local range = get_visual_range()
  local file_name = vim.api.nvim_buf_get_name(0)
  local cmd = string.format(
    'vert Git log --max-count=30 -L %d,%d:%s',
    range.start, range.finish, file_name
  )
  vim.cmd(cmd)
end, { desc = 'Git log for selected lines' })

vim.keymap.set('n', '<leader>gL', function()
  local count = vim.v.count
  local max_count_arg = count > 0 and string.format('--max-count=%d', count) or ''
  vim.cmd(string.format(
    'Git log %s -p -m --first-parent -P -- %s',
    max_count_arg, vim.fn.expand('%')
  ))
end, { desc = 'Git log with patches for current file' })

return M