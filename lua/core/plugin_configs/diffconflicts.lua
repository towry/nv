-- DiffConflicts configuration for git mergetool
local M = {}

-- Load diffconflicts plugin eagerly
-- This is required for git mergetool to work properly
local git_utils = require('utils.git')
if git_utils.is_mergetool() then
  vim.cmd('packadd diffconflicts')
end

return M
