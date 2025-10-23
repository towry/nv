-- Native LSP config for TypeScript/JavaScript using typescript-language-server
-- Consumed by vim.lsp.config('tsserver', conf)
return {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = {
    'typescript', 'typescriptreact', 'typescript.tsx',
    'javascript', 'javascriptreact', 'javascript.jsx',
  },
  single_file_support = true,
}