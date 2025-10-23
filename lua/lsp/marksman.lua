-- Native LSP config for Markdown (marksman)
-- Consumed by vim.lsp.config('marksman', conf)
return {
  cmd = { 'marksman', 'server' },
  filetypes = { 'markdown', 'quarto' },
  single_file_support = true,
}