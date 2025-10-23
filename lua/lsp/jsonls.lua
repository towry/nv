-- Native LSP config for JSON/JSONC
-- Consumed by vim.lsp.config('jsonls', conf)
return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  single_file_support = true,
}