-- Native LSP config for Bash/sh
-- Consumed by vim.lsp.config('bashls', conf)
return {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh', 'bash', 'zsh' },
  single_file_support = true,
}