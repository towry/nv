-- Native LSP config for CSS/SCSS/LESS
-- Consumed by vim.lsp.config.cssls = conf
return {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  single_file_support = true,
}