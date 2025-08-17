---
--- Only add essenstial keys.
-- Basic keymaps
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Quick save
map('n', '<leader>w', ':w<CR>', opts)
-- 0: go to first column; if already at first column, toggle fold on current line
map('n', '0', [[col('.') == 1 ? 'za' : '0']], { noremap = true, silent = true, expr = true })

-- =============== PLUGINS

-- fzf-lua keymaps (grouped under <leader>f for "find")
map('n', '<leader>ff', ":lua require('fzf-lua').files()<CR>", opts)
map('n', '<leader>fg', ":lua require('fzf-lua').live_grep()<CR>", opts)
map('n', '<leader>fb', ":lua require('fzf-lua').buffers()<CR>", opts)
map('n', '<leader>fr', ":lua require('fzf-lua').oldfiles()<CR>", opts)
map('n', '<leader>fl', ":lua require('fzf-lua').resume()<CR>", opts)
map('n', '<leader>fs', ":lua require('fzf-lua').lsp_document_symbols()<CR>", opts)
map('n', '<leader>fw', ":lua require('fzf-lua').lsp_workspace_symbols()<CR>", opts)
map('n', '<leader>fd', ":lua require('fzf-lua').lsp_definitions()<CR>", opts)
map('n', '<leader>ft', ":lua require('fzf-lua').lsp_typedefs()<CR>", opts)

-- legendary.nvim keymap (keybind finder)
map('n', '<leader>k', ":lua require('legendary').find()<CR>", opts)


return {}
