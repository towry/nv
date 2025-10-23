-- mini.statusline configuration (safe)
local M = {}

local ok, ms = pcall(require, 'mini.statusline')
if not ok then
  return M
end

ms.setup({
  -- Enable icons (mini.icons already initialized in plugins.lua)
  use_icons = true,
  
  -- Custom active content with all required sections
  content = {
    active = function()
      local mode, mode_hl = ms.section_mode({ trunc_width = 120 })
      local git = ms.section_git({ trunc_width = 75 })
      local diagnostics = ms.section_diagnostics({ trunc_width = 75 })
      local filename = ms.section_filename({ trunc_width = 140 })
      local fileinfo = ms.section_fileinfo({ trunc_width = 120 })
      local lsp = ms.section_lsp({ trunc_width = 75 })
      local location = ms.section_location({ trunc_width = 75 })
      
      return ms.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics } },
        '%<', -- Mark general truncation point
        { hl = 'MiniStatuslineFilename', strings = { filename } },
        '%=', -- End left alignment
        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
        { hl = 'MiniStatuslineFileinfo', strings = { lsp } }, -- NOTE: section_lsp_hl() doesn't exist; using stable group instead (https://nvim-mini.org/mini.nvim/doc/mini-statusline.html)
        { hl = 'MiniStatuslineLocation', strings = { location } },
      })
    end,
  },
})

return M