-- Minimal highlight overrides for Neovim default colorscheme
-- Targets pink/magenta popup colors while preserving terminal harmony

local M = {}

-- Helper to get terminal color hex values if available
local function term_hex(i)
  return vim.g["terminal_color_" .. i] or string.format("#%06x", i)
end

-- Set highlight group with proper fallbacks
local function set(group, spec)
  local hl = {}

  -- Handle colors
  if spec.fg then
    hl.fg = vim.g["terminal_color_" .. spec.fg] or spec.fg
  end
  if spec.bg then
    hl.bg = vim.g["terminal_color_" .. spec.bg] or spec.bg
  end

  -- Handle cterm colors for better terminal compatibility
  if spec.ctermfg then
    hl.ctermfg = spec.ctermfg
  end
  if spec.ctermbg then
    hl.ctermbg = spec.ctermbg
  end

  -- Handle other attributes
  if spec.bold then
    hl.bold = spec.bold
  end
  if spec.italic then
    hl.italic = spec.italic
  end
  if spec.reverse then
    hl.reverse = spec.reverse
  end

  vim.api.nvim_set_hl(0, group, hl)
end

-- Apply all highlight overrides
function M.apply()
  -- Core floating windows
  set("NormalFloat", { fg = 15, bg = 0, ctermfg = 15, ctermbg = 0 })
  set("FloatBorder", { fg = 8, bg = 0, ctermfg = 8, ctermbg = 0 })
  set("FloatTitle", { fg = 15, bg = 8, ctermfg = 15, ctermbg = 8, bold = true })

  -- Popup menu (completion)
  set("Pmenu", { fg = 15, bg = 8, ctermfg = 15, ctermbg = 8 })
  set("PmenuSel", { fg = 0, bg = 7, ctermfg = 0, ctermbg = 7 })
  set("PmenuSbar", { fg = 15, bg = 8, ctermfg = 15, ctermbg = 8 })
  set("PmenuThumb", { fg = 7, bg = 7, ctermfg = 7, ctermbg = 7 })

  -- LSP/Diagnostics floating
  set("DiagnosticFloatingError", { fg = 1, bg = 0, ctermfg = 1, ctermbg = 0 })
  set("DiagnosticFloatingWarn", { fg = 3, bg = 0, ctermfg = 3, ctermbg = 0 })
  set("DiagnosticFloatingInfo", { fg = 6, bg = 0, ctermfg = 6, ctermbg = 0 })
  set("DiagnosticFloatingHint", { fg = 4, bg = 0, ctermfg = 4, ctermbg = 0 })

  -- LSP signature
  set("LspSignatureActiveParameter", { fg = 0, bg = 4, ctermfg = 0, ctermbg = 4, bold = true })

  -- nvim-tree (if used)
  set("NvimTreeNormalFloat", { fg = 15, bg = 0, ctermfg = 15, ctermbg = 0 })

  -- nvim-notify (if used)
  set("NotifyBackground", { fg = 15, bg = 0, ctermfg = 15, ctermbg = 0 })
  set("NotifyERRORBorder", { fg = 1, bg = 0, ctermfg = 1, ctermbg = 0 })
  set("NotifyWARNBorder", { fg = 3, bg = 0, ctermfg = 3, ctermbg = 0 })
  set("NotifyINFOBorder", { fg = 6, bg = 0, ctermfg = 6, ctermbg = 0 })
  set("NotifyDEBUGBorder", { fg = 8, bg = 0, ctermfg = 8, ctermbg = 0 })
  set("NotifyTRACEBorder", { fg = 4, bg = 0, ctermfg = 4, ctermbg = 0 })

  -- nvim-cmp (if used)
  set("CmpBorder", { fg = 8, bg = 0, ctermfg = 8, ctermbg = 0 })
  set("CmpDocBorder", { fg = 8, bg = 0, ctermfg = 8, ctermbg = 0 })
  set("CmpDocNormal", { fg = 15, bg = 0, ctermfg = 15, ctermbg = 0 })
  set("CmpItemAbbr", { fg = 15, ctermfg = 15 })
  set("CmpItemAbbrMatch", { fg = 7, ctermfg = 7, bold = true })
  set("CmpItemAbbrMatchFuzzy", { fg = 7, ctermfg = 7, bold = true })
  set("CmpItemKind", { fg = 6, ctermfg = 6 })
  set("CmpItemMenu", { fg = 8, ctermfg = 8 })

  -- Quickfix/location windows
  set("QuickFixLine", { fg = 15, bg = 4, ctermfg = 15, ctermbg = 4 })
end

-- Setup function with autocmd for persistence
function M.setup()
  -- Apply immediately
  M.apply()

  -- Reapply on colorscheme changes
  local group = vim.api.nvim_create_augroup("HighlightOverrides", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = M.apply,
    desc = "Reapply highlight overrides after colorscheme change"
  })
end

-- Auto-setup when module is loaded
M.setup()

return M