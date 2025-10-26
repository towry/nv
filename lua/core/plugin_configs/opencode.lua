-- opencode.nvim configuration and keymaps
-- Sets options first (global), then safely loads plugin and defines keymaps.

-- NOTE: Requires `o.autoread = true` in options.lua for auto_reload
vim.g.opencode_opts = {
  -- Leave `port = nil` to auto-discover opencode in CWD
  auto_reload = true,
  -- Minimal UI tweaks (rely on plugin defaults otherwise)
  input = {
    prompt = "Ask opencode: ",
    icon = "󱚣 ",
  },
  select = {
    prompt = "Prompt opencode: ",
  },
}

local ok, opencode = pcall(require, 'opencode')
if not ok then
  vim.notify('opencode.nvim not found, skipping setup', vim.log.levels.WARN)
  return
end

local map = vim.keymap.set
local km_opts = { silent = true, noremap = true }

-- Ask about @this (selection if any, else cursor context); submit immediately
map({ 'n', 'x' }, '<leader>oa', function() opencode.ask('@this: ', { submit = true }) end, vim.tbl_extend('force', km_opts, { desc = 'Ask about this' }))

-- Select prompt from library
map({ 'n', 'x' }, '<leader>os', function() opencode.select() end, vim.tbl_extend('force', km_opts, { desc = 'Select prompt' }))

-- Add @this content to the thread (no submit)
map({ 'n', 'x' }, '<leader>o+', function() opencode.prompt('@this') end, vim.tbl_extend('force', km_opts, { desc = 'Add this' }))

-- Toggle embedded opencode terminal (requires snacks.nvim)
map('n', '<leader>ot', function() opencode.toggle() end, vim.tbl_extend('force', km_opts, { desc = 'Toggle embedded' }))

-- Pick a command to send to opencode
map('n', '<leader>oc', function() opencode.command() end, vim.tbl_extend('force', km_opts, { desc = 'Select command' }))

-- Handy session control commands
map('n', '<leader>on', function() opencode.command('session_new') end, vim.tbl_extend('force', km_opts, { desc = 'New session' }))
map('n', '<leader>oi', function() opencode.command('session_interrupt') end, vim.tbl_extend('force', km_opts, { desc = 'Interrupt session' }))
map('n', '<leader>oA', function() opencode.command('agent_cycle') end, vim.tbl_extend('force', km_opts, { desc = 'Cycle agent' }))

-- Scroll the TUI's messages
map('n', '<S-C-u>', function() opencode.command('messages_half_page_up') end, vim.tbl_extend('force', km_opts, { desc = 'Messages half page up' }))
map('n', '<S-C-d>', function() opencode.command('messages_half_page_down') end, vim.tbl_extend('force', km_opts, { desc = 'Messages half page down' }))

-- End of opencode.nvim config