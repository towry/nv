-- mini.statusline configuration (maintainable component-based structure)
--
-- QUICK GUIDE:
-- 1. Add new components: Define functions in CUSTOM COMPONENTS section
-- 2. Use components: Add them to build_active_statusline() LEFT/RIGHT sections
-- 3. Reorder: Change the order in ms.combine_groups() table
-- 4. Adjust truncation: Modify trunc_width values for each component
-- 5. Change highlights: Use different hl values (see Available Highlights below)
--
-- Available Highlights:
--   - MiniStatuslineDevinfo   (git, diagnostics)
--   - MiniStatuslineFilename  (filename)
--   - MiniStatuslineFileinfo  (filetype, encoding)
--   - MiniStatuslineLocation  (line:col, percentage)
--   - mode_hl                 (dynamic based on mode)
--
-- Example: Adding a custom component
--   1. Define: local function section_my_component(trunc_width) ... end
--   2. Call: local my_comp = section_my_component(75)
--   3. Add: { hl = 'MiniStatuslineFileinfo', strings = { my_comp } }
--
local M = {}

local ok, ms = pcall(require, 'mini.statusline')
if not ok then
  return M
end

-- ============================================================================
-- CUSTOM COMPONENTS
-- ============================================================================
-- Add your custom statusline components here. Each function should:
-- 1. Accept a trunc_width parameter for truncation handling
-- 2. Return a string to display (or empty string if truncated/unavailable)
-- 3. Be self-contained and testable
-- ============================================================================

--- Custom LSP section showing active server names
--- @param trunc_width number Minimum window width to display
--- @return string LSP section content
local function section_lsp_servers(trunc_width)
  if ms.is_truncated(trunc_width) then return '' end
  
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return '' end
  
  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
  end
  
  return '󰰎 ' .. table.concat(names, ',')
end

-- ============================================================================
-- STATUSLINE LAYOUT CONFIGURATION
-- ============================================================================
-- Define the layout by listing components in order.
-- LEFT section: components before '%='
-- RIGHT section: components after '%='
-- ============================================================================

--- Build the active statusline content
--- @return string Statusline content string
local function build_active_statusline()
  -- LEFT SECTION: Mode, Git, Diagnostics, Filename
  local mode, mode_hl = ms.section_mode({ trunc_width = 120 })
  local git           = ms.section_git({ trunc_width = 75 })
  local diagnostics   = ms.section_diagnostics({ trunc_width = 75 })
  local filename      = ms.section_filename({ trunc_width = 140 })
  
  -- RIGHT SECTION: Fileinfo, LSP, Location
  local fileinfo      = ms.section_fileinfo({ trunc_width = 120 })
  local lsp           = section_lsp_servers(75)
  local location      = ms.section_location({ trunc_width = 75 })
  
  -- Combine into groups with highlights
  return ms.combine_groups({
    -- Left side
    { hl = mode_hl,                   strings = { mode } },
    { hl = 'MiniStatuslineDevinfo',   strings = { git, diagnostics } },
    '%<', -- Truncation point
    { hl = 'MiniStatuslineFilename',  strings = { filename } },
    
    -- Separator (right-align everything after this)
    '%=',
    
    -- Right side
    { hl = 'MiniStatuslineFileinfo',  strings = { fileinfo } },
    { hl = 'MiniStatuslineFileinfo',  strings = { lsp } },
    { hl = 'MiniStatuslineLocation',  strings = { location } },
  })
end

-- ============================================================================
-- SETUP
-- ============================================================================

ms.setup({
  use_icons = true,
  content = {
    active = build_active_statusline,
  },
})

return M

