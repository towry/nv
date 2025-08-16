-- lualine minimal config (safe)
local M = {}

local ok, lualine = pcall(require, 'lualine')
if not ok then
  return M
end

lualine.setup({ options = { theme = 'auto' } })

return M
