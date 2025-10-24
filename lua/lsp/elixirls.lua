-- Native LSP config for Elixir (ElixirLS)
-- Consumed by vim.lsp.config.elixirls = conf
return {
  cmd = { 'elixir-ls' },
  filetypes = { 'elixir', 'eelixir', 'heex', 'surface' },
  single_file_support = true,
}