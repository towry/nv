-- Visual selection utilities for Neovim
-- NOTE: Uses Neovim Lua API (vim.api.*) only
-- This reads visual marks ('< and '>) which are set AFTER exiting visual mode

local M = {}

-- Get visual selection as text using pure vim.api
-- Works when called after leaving Visual mode (marks '<,'> are set)
-- Handles character-wise and line-wise selections. Block-wise returns a
-- flattened slice between corners. Consumers can post-process if needed.
function M.get_visual_selection()
  local buf = 0
  local srow, scol = unpack(vim.api.nvim_buf_get_mark(buf, '<'))
  local erow, ecol = unpack(vim.api.nvim_buf_get_mark(buf, '>'))

  -- Marks not set -> empty
  if srow == 0 or erow == 0 then
    return ''
  end

  -- Normalize order
  if (srow > erow) or (srow == erow and scol > ecol) then
    srow, erow = erow, srow
    scol, ecol = ecol, scol
  end

  -- Convert to 0-based rows for nvim_buf_get_text; cols are already 0-based
  local start_row = srow - 1
  local end_row = erow - 1
  local start_col = math.max(0, scol)
  local end_col_excl = math.max(0, ecol + 1) -- make end column inclusive

  local ok, lines = pcall(vim.api.nvim_buf_get_text, buf, start_row, start_col, end_row, end_col_excl, {})
  if not ok or type(lines) ~= 'table' or #lines == 0 then
    return ''
  end

  return table.concat(lines, '\n')
end

return M
