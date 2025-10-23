-- Native LSP config for TypeScript/JavaScript (prefer VTSLS if present)
-- Consumed by vim.lsp.config('ts_ls', conf)
-- NOTE: core/lsp.lua prefers this over tsserver when this module exists
local cmd
if vim.fn.executable('vtsls') == 1 then
  cmd = { 'vtsls' }
else
  -- Fallback to typescript-language-server; install vtsls for better perf/features
  cmd = { 'typescript-language-server', '--stdio' }
end
return {
  cmd = cmd,
  filetypes = {
    'typescript', 'typescriptreact', 'typescript.tsx',
    'javascript', 'javascriptreact', 'javascript.jsx',
  },
  single_file_support = true,
}