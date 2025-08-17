-- Fugitive configuration
local M = {}

-- Fugitive setup
vim.g.fugitive_git_command = 'git'

-- Setup fugitive keymaps with descriptions (which-key will pick these up automatically)
vim.keymap.set('n', '<leader>gs', '<cmd>Git<cr>', { desc = 'Git status' })
vim.keymap.set('n', '<leader>gb', '<cmd>Git blame<cr>', { desc = 'Git blame' })
vim.keymap.set('n', '<leader>gd', '<cmd>Gdiffsplit<cr>', { desc = 'Git diff split' })

return M