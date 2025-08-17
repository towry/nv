-- Minimal Neonvim init.lua
-- Keep config small and use native pack for plugins

vim.g.mapleader = ' '

-- bootstrap: add lua path based on current init.lua location (works with -u)
local config_path = vim.fn.fnamemodify(vim.env.MYVIMRC or (debug.getinfo(1, 'S').source:sub(2)), ':h')
package.path = config_path .. '/lua/?.lua;' .. config_path .. '/lua/?/init.lua;' .. package.path

-- core modules
local core = {
  'core.options',
  'core.keymaps',
  'core.autocmds',
  'core.plugins',
}

for _, mod in ipairs(core) do
  local ok, err = pcall(require, mod)
  if not ok then
    vim.notify('Error loading ' .. mod .. ': ' .. tostring(err), vim.log.levels.ERROR)
  end
end

-- lightweight status line
vim.o.laststatus = 2

-- Helpful message
vim.api.nvim_create_autocmd('VimEnter', { once = true, callback = function()
  vim.defer_fn(function()
    print('neonvim: minimal config loaded')
  end, 100)
end })
