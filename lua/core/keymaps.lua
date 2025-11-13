---
--- Only add essenstial keys.
-- Basic keymaps
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Quick save
map('n', '<leader>w', ':w<CR>', opts)
map('i', 'jk', '<Esc>', opts)
-- 0: go to first column; if already at first column, toggle fold on current line
map('n', '0', [[col('.') == 1 ? 'za' : '0']], { noremap = true, silent = true, expr = true })

-- =============== PLUGINS

-- legendary.nvim keymap (keybind finder)
map('n', '<leader>k', ":lua require('utils.legendary').find()<CR>", opts)
map('x', '<leader>k', "<Cmd>lua require('utils.legendary').find()<CR>", opts)

-- YankCode: Copy selected code with file path and line numbers
map('x', '<leader>yc', ':YankCode<CR>', opts)

-- Git mergetool conditional keymaps
local git_utils = require('utils.git')
if git_utils.is_mergetool() then
  vim.keymap.set('n', '<localleader>w', ':w|cq 0', {
    desc = 'Mergetool: write and exit safely',
    nowait = true,
    noremap = true
  })
  vim.keymap.set('n', '<localleader>c', ':cq 1', {
    desc = 'Mergetool: abort merge',
    nowait = true,
    noremap = true
  })
end

return {}
