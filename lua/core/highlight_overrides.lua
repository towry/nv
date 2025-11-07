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
  -- Core floating windows - let vim colorscheme handle backgrounds naturally
  set("NormalFloat", { fg = "NONE", bg = "NONE" })
  set("FloatBorder", { fg = "NONE", bg = "NONE" })
  set("FloatTitle", { fg = "NONE", bg = "NONE", bold = true })

  -- Popup menu (completion) - use subtle background differentiation
  set("Pmenu", { fg = "NONE", bg = "NONE" })
  set("PmenuSel", { fg = "NONE", bg = "NONE", bold = true })
  set("PmenuSbar", { fg = "NONE", bg = "NONE" })
  set("PmenuThumb", { fg = "NONE", bg = "NONE" })

  -- LSP/Diagnostics floating - blend with main background
  set("DiagnosticFloatingError", { fg = "NONE", bg = "NONE" })
  set("DiagnosticFloatingWarn", { fg = "NONE", bg = "NONE" })
  set("DiagnosticFloatingInfo", { fg = "NONE", bg = "NONE" })
  set("DiagnosticFloatingHint", { fg = "NONE", bg = "NONE" })

  -- LSP signature
  set("LspSignatureActiveParameter", { fg = "NONE", bg = "NONE", bold = true })

  -- nvim-tree (if used)
  set("NvimTreeNormalFloat", { fg = "NONE", bg = "NONE" })

  -- nvim-notify (if used)
  set("NotifyBackground", { fg = "NONE", bg = "NONE" })
  set("NotifyERRORBorder", { fg = "NONE", bg = "NONE" })
  set("NotifyWARNBorder", { fg = "NONE", bg = "NONE" })
  set("NotifyINFOBorder", { fg = "NONE", bg = "NONE" })
  set("NotifyDEBUGBorder", { fg = "NONE", bg = "NONE" })
  set("NotifyTRACEBorder", { fg = "NONE", bg = "NONE" })

  -- nvim-cmp (if used)
  set("CmpBorder", { fg = "NONE", bg = "NONE" })
  set("CmpDocBorder", { fg = "NONE", bg = "NONE" })
  set("CmpDocNormal", { fg = "NONE", bg = "NONE" })
  set("CmpItemAbbr", { fg = "NONE" })
  set("CmpItemAbbrMatch", { fg = "NONE", bold = true })
  set("CmpItemAbbrMatchFuzzy", { fg = "NONE", bold = true })
  set("CmpItemKind", { fg = "NONE" })
  set("CmpItemMenu", { fg = "NONE" })

  -- Quickfix/location windows
  set("QuickFixLine", { fg = "NONE", bg = "NONE", bold = true })
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