-- Native LSP config for YAML
-- Consumed by vim.lsp.config('yamlls', conf)
return {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml', 'yml' },
  single_file_support = true,
}