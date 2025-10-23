-- Native LSP config for HTML
-- Consumed by vim.lsp.config('html', conf)
return {
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html' },
  single_file_support = true,
}