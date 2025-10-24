-- Native LSP config for Python (Pyright)
-- Consumed by vim.lsp.config.pyright = conf
return {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  single_file_support = true,
}