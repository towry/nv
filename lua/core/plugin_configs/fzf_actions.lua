-- fzf-lua custom actions
local M = {}
local wrap = vim.schedule_wrap

-- Window picker functionality (simplified version)
local function after_set_current_win()
  -- Simple window selection - just use the current window for now
  -- Can be enhanced later with a proper window picker
  return true
end

M.files_open_in_window = wrap(function(selected, opts)
  local actions = require("fzf-lua.actions")
  if not after_set_current_win() then return end
  actions.file_edit(selected, opts)
end)

M.buffers_open_in_window = wrap(function(selected, opts)
  local actions = require("fzf-lua.actions")
  if not after_set_current_win() then return end
  actions.file_edit(selected, opts)
end)

M.buffers_open_default = wrap(function(selected, opts)
  local actions = require("fzf-lua.actions")
  local path = require("fzf-lua.path")

  if #selected > 1 then
    actions.file_edit(selected, opts)
    return
  end

  local entry = path.entry_to_file(selected[1], opts)
  if not entry.bufnr then return end
  assert(type(entry.bufnr) == "number")

  -- Focus or go to the buffer
  vim.api.nvim_set_current_buf(entry.bufnr)
end)

return M