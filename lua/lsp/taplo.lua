-- Native LSP config for TOML (taplo)
-- Consumed by vim.lsp.config.taplo = conf
return {
  cmd = { 'taplo', 'lsp', 'stdio' },
  filetypes = { 'toml' },
  single_file_support = true,
}