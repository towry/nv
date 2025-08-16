-- Basic keymaps
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Quick save
map('n', '<leader>w', ':w<CR>', opts)
-- 0: go to first column; if already at first column, toggle fold on current line
map('n', '0', [[col('.') == 1 ? 'za' : '0']], { noremap = true, silent = true, expr = true })

-- =============== PLUGINS

-- fzf-lua keymaps (files, live grep, buffers, help tags)
map('n', '<leader>p', ":lua require('fzf-lua').files()<CR>", opts)
map('n', '<leader>f', ":lua require('fzf-lua').live_grep()<CR>", opts)
map('n', '<leader>b', ":lua require('fzf-lua').buffers()<CR>", opts)

-- legendary.nvim keymap (keybind finder)
map('n', '<leader>k', ":lua require('legendary').find()<CR>", opts)


return {}
