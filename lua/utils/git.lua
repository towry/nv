-- Git/JJ mergetool detection functions

local cache = {} ---@type table<(fun()), table<string, any>>

---@generic T: fun()
---@param fn T
---@return T
local function util_memoize(fn)
  return function(...)
    local key = vim.inspect({ ... })
    cache[fn] = cache[fn] or {}
    if cache[fn][key] == nil then cache[fn][key] = fn(...) end
    return cache[fn][key]
  end
end

-- Check if current buffer is in a jj-resolve tool directory
local function is_in_jj_resolve_tool()
  local tail = vim.fn.expand("%:h:t")
  -- tail is string like: jj-resolve-<rev>
  -- we need to test the jj-resolve-
  local args = { "jj-resolve-" }

  for _, v in ipairs(args) do
    if tail:match(v) then
      vim.g.nvim_is_start_as_merge_tool = 1
      return true
    end
  end
  return false
end

-- Check if currently performing a merge operation
local function is_performing_merge()
  if vim.g.nvim_is_start_as_merge_tool == 1 then return true end
  
  local tail = vim.fn.expand("%:t")
  local args = { "MERGE_MSG", "COMMIT_EDITMSG", "jj-resolve-" }
  
  for _, v in ipairs(args) do
    if tail:match(v) then
      vim.g.nvim_is_start_as_merge_tool = 1
      return true
    end
  end
  return false
end

-- Check if nvim is started as a mergetool
local function is_mergetool()
  if vim.fn.argc(-1) == 0 then return false end
  
  local argv = vim.v.argv
  local args = { { "-d" }, { "-c", "DiffConflicts" } }
  
  -- each table in args is pairs of args that may exists in argv to determine the
  -- return value is true or false.
  for _, arg in ipairs(args) do
    local is_match = true
    for _, v in ipairs(arg) do
      if not vim.tbl_contains(argv, v) then 
        is_match = false 
        break
      end
    end
    if is_match then
      vim.g.nvim_is_start_as_merge_tool = 1
      return true
    end
  end

  return is_performing_merge() or is_in_jj_resolve_tool()
end

-- Memoized version of is_mergetool
local memoized_is_mergetool = util_memoize(is_mergetool)

return {
  is_mergetool = memoized_is_mergetool,
  is_in_jj_resolve_tool = is_in_jj_resolve_tool,
  is_performing_merge = is_performing_merge,
}