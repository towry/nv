-- Treesitter configuration for syntax highlighting and indentation
local ok, configs = pcall(require, 'nvim-treesitter.configs')
if not ok then
  return
end

configs.setup({
  ensure_installed = {
    'lua', 'typescript', 'tsx', 'javascript', 'go', 'python', 'rust', 'bash',
    'markdown', 'json', 'yaml', 'toml'
  },
  highlight = { enable = true, additional_vim_regex_highlighting = false },
  indent = { enable = true },  -- Enable treesitter-based indentation
  incremental_selection = { enable = false },
})