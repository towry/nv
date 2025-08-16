-- fzf-lua configuration (safe)
local M = {}

local ok, fzf = pcall(require, 'fzf-lua')
if not ok then
  return M
end

fzf.setup({
  winopts = { width = 0.85, height = 0.85 },
  files = { rg_opts = '--hidden --glob "!**/.git/*"' },
  keymap = {
    fzf = {
      -- Allow Esc to close fzf window
      ['esc'] = 'abort',
    },
  },
})

return M
