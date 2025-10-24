-- Native LSP config for Lua (LuaLS)
-- Consumed by vim.lsp.config.lua_ls = conf
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { globals = { 'vim' } },
    },
  },
  single_file_support = true,
}