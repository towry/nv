-- Minimal Mason shim for optional LSP tool management
-- Only initializes if Mason and Mason-lspconfig are available
-- Does not auto-install anything or set up handlers

local ok_mason, mason = pcall(require, 'mason')
local ok_mason_lspconfig, mason_lspconfig = pcall(require, 'mason-lspconfig')

if ok_mason and ok_mason_lspconfig then
  mason.setup({
    ui = {
      border = 'single'
    }
  })
  
  mason_lspconfig.setup({})
end