-- Lightweight autocommands

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank({timeout = 150}) end,
})

-- Create undo directory if missing
local undodir = vim.fn.stdpath('config') .. '/undo'
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, 'p')
end

return {}
