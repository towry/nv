-- Basic keymaps
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Quick save
map('n', '<leader>w', ':w<CR>', opts)
-- Toggle relative numbers
map('n', '<leader>n', ':set relativenumber!<CR>', opts)
-- Clear search
map('n', '<leader><space>', ':nohlsearch<CR>', opts)

-- fzf-lua keymaps (files, live grep, buffers, help tags)
map('n', '<leader>p', ":lua require('fzf-lua').files()<CR>", opts)
map('n', '<leader>f', ":lua require('fzf-lua').live_grep()<CR>", opts)
map('n', '<leader>b', ":lua require('fzf-lua').buffers()<CR>", opts)
map('n', '<leader>h', ":lua require('fzf-lua').help_tags()<CR>", opts)

return {}
