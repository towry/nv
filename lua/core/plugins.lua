-- Minimal plugin management using built-in vim.pack
-- Keeps the config lightweight: only a few small, commonly used plugins as examples.

local M = {}

-- Only run when vim.pack is available (Neovim recent versions)
local has_vim_pack = type(vim.pack) == 'table'
if not has_vim_pack then
  vim.notify('vim.pack not available; skipping plugin management', vim.log.levels.WARN)
  return M
end

-- Example plugins: small and useful. Adjust as you like.
local plugins = {
  -- Utility library many plugins depend on
  'https://github.com/nvim-lua/plenary.nvim',
  -- Lightweight statusline
  'https://github.com/nvim-lualine/lualine.nvim',
  -- FZF Lua (fuzzy finder)
  'https://github.com/ibhagwan/fzf-lua',
}

-- Add and optionally load plugins. Using confirm=false will skip interactive prompt in headless.
local ok, err = pcall(function()
  vim.pack.add(plugins, { confirm = false })
end)
if not ok then
  vim.notify('Error while adding plugins: ' .. tostring(err), vim.log.levels.ERROR)
end

-- Load per-plugin configuration from `lua/core/plugin_configs/*`.
-- Each config is responsible for safe require and not failing if the
-- plugin is not present.
pcall(require, 'core.plugin_configs.lualine')
pcall(require, 'core.plugin_configs.fzf')

return M
