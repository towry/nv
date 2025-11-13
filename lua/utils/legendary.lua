-- Utility wrappers for working with legendary.nvim
-- Adds a safe require and a single registration surface to keep repeated patterns concise
-- Includes EmmyLua annotations to improve developer experience with LSPs like lua-language-server

---@alias LegendaryCommand table --[[ A command spec; library accepts multiple structures ]]
---@alias LegendaryKeymap table --[[ A keymap spec for legendary.keymaps API ]]

---@class LegendaryItem
---@field itemgroup string|nil
---@field description string|nil
---@field icon string|nil
---@field commands LegendaryCommand[]|nil
---@field keymaps LegendaryKeymap[]|nil

---@class LegendarySpec
---@field setup table|nil
---@field commands LegendaryCommand[]|nil
---@field keymaps LegendaryKeymap[]|nil
---@field itemgroups LegendaryItem[]|nil
---@field items LegendaryItem[]|nil

---@class LegendaryUtil
---@field register fun(spec: LegendarySpec)
local M = {}

---Safely require legendary.nvim; if not installed, return nil and warn
---@return table|nil
local function safe_require()
  local ok, legendary = pcall(require, 'legendary')
  if not ok or legendary == nil then
    vim.notify('legendary.nvim not found, skipping registration', vim.log.levels.WARN)
    return nil
  end
  return legendary
end

---Normalize a list of arbitrary "items" into itemgroups for legendary.itemgroups API
---@param items LegendaryItem[]|nil
---@return LegendaryItem[]
local function normalize_items_to_groups(items)
  if type(items) ~= 'table' then
    return {}
  end

  local groups = {}
  for _, it in ipairs(items) do
    -- pass-through when already itemgroup
    if it.itemgroup then
      table.insert(groups, it)
    else
      local group = {
        itemgroup = it.itemgroup or ('Group ' .. tostring(#groups + 1)),
        description = it.description,
        icon = it.icon,
        commands = it.commands,
        keymaps = it.keymaps,
      }
      if group.commands or group.keymaps then
        table.insert(groups, group)
      end
    end
  end

  return groups
end

---Register a collection of Legendary spec (setup/commands/keymaps/itemgroups/items)
---@param spec LegendarySpec
---@return nil
function M.register(spec)
  local legendary = safe_require()
  if not legendary then
    return
  end

  if not spec or type(spec) ~= 'table' then
    return
  end

  -- setup table
  if spec.setup and type(spec.setup) == 'table' and type(legendary.setup) == 'function' then
    legendary.setup(spec.setup)
  end

  -- direct commands/keymaps
  if spec.commands and type(spec.commands) == 'table' and type(legendary.commands) == 'function' then
    legendary.commands(spec.commands)
  end

  if spec.keymaps and type(spec.keymaps) == 'table' and type(legendary.keymaps) == 'function' then
    legendary.keymaps(spec.keymaps)
  end

  -- itemgroups
  if spec.itemgroups and type(spec.itemgroups) == 'table' and type(legendary.itemgroups) == 'function' then
    legendary.itemgroups(spec.itemgroups)
  end

  -- items: historic/incorrect usage - attempt to convert into itemgroups or register commands/keymaps
  if spec.items and type(spec.items) == 'table' then
    local groups = normalize_items_to_groups(spec.items)
    if #groups > 0 and type(legendary.itemgroups) == 'function' then
      legendary.itemgroups(groups)
    else
      -- Fall back to registering commands/keymaps directly where possible
      for _, it in ipairs(spec.items) do
        if it.commands and type(it.commands) == 'table' and type(legendary.commands) == 'function' then
          legendary.commands(it.commands)
        end
        if it.keymaps and type(it.keymaps) == 'table' and type(legendary.keymaps) == 'function' then
          legendary.keymaps(it.keymaps)
        end
      end
    end
  end
end


---Safely call legendary.find() if available
---@return nil
function M.find()
  local legendary = safe_require()
  if not legendary then
    return
  end

  if type(legendary.find) == 'function' then
    legendary.find()
  end
end

return M

