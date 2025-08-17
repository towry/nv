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
  -- Which-key (key binding hints) - loaded early to avoid race conditions
  'https://github.com/folke/which-key.nvim',
  -- Lightweight statusline
  'https://github.com/nvim-lualine/lualine.nvim',
  -- FZF Lua (fuzzy finder)
  'https://github.com/ibhagwan/fzf-lua',
  -- Legendary.nvim (keybind finder and management)
  'https://github.com/mrjones2014/legendary.nvim',
  -- Git integration
  'https://github.com/tpope/vim-fugitive',
  'https://github.com/lewis6991/gitsigns.nvim',
  -- AI Copilot
  'https://github.com/github/copilot.vim',
  -- Mini.nvim (library of Lua modules)
  'https://github.com/echasnovski/mini.nvim',
}

-- Add and optionally load plugins. Using confirm=false will skip interactive prompt in headless.
local ok, err = pcall(function()
  vim.pack.add(plugins, { confirm = false })
end)
if not ok then
  vim.notify('Error while adding plugins: ' .. tostring(err), vim.log.levels.ERROR)
end

-- Eager-load mini.nvim so mini.* configs can initialize during verification
pcall(function()
  vim.cmd('packadd mini.nvim')
end)

-- NOTE: mini.nvim managed by vim.pack; see claude.md Autoload patterns.

-- Initialize mini.icons early to provide devicons for downstream consumers (e.g., fzf-lua)
-- This ensures icons are available on first use without requiring explicit initialization
pcall(function()
  require('mini.icons').setup()
  require('mini.icons').mock_nvim_web_devicons()
end)

-- Initialize mini.jump2d (Flash replacement): labelled jumps
-- NOTE: Defaults are sufficient; mapping is defined in which_key.lua
pcall(function()
  require('mini.jump2d').setup()
end)



-- Load per-plugin configuration from `lua/core/plugin_configs/*`.
-- Each config is responsible for safe require and not failing if the
-- plugin is not present.
pcall(require, 'core.plugin_configs.which_key')
pcall(require, 'core.plugin_configs.lualine')
pcall(require, 'core.plugin_configs.fzf')
pcall(require, 'core.plugin_configs.fzf_keymaps')
pcall(require, 'core.plugin_configs.legendary')
pcall(require, 'core.plugin_configs.fugitive')
pcall(require, 'core.plugin_configs.gitsigns')
pcall(require, 'core.plugin_configs.copilot')
pcall(require, 'core.plugin_configs.mini_completion')
pcall(require, 'core.plugin_configs.mini_snippets')
pcall(require, 'core.plugin_configs.mini_splitjoin')
pcall(require, 'core.plugin_configs.mini_surround')
pcall(require, 'core.plugin_configs.mini_operators')

return M
