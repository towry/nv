# Legendary.nvim Setup Patterns

## Correct API Functions

Legendary.nvim provides specific functions for registering different item types:

- ✅ `legendary.commands()` - Register commands
- ✅ `legendary.keymaps()` - Register keymaps  
- ✅ `legendary.itemgroups()` - Register itemgroups
- ❌ `legendary.items()` - **DOES NOT EXIST**

## Registration Examples

### Flat Registration (Recommended for Simple Cases)

```lua
pcall(function()
  local legendary = require('legendary')
  
  -- Register commands
  legendary.commands({
    {
      ':YankCode',
      description = '󰆏 YankCode: Copy selected code with file path and line numbers',
    },
  })
  
  -- Register keymaps
  legendary.keymaps({
    {
      '<leader>yc',
      ':YankCode<CR>',
      description = '󰆏 YankCode: Copy code with context',
      mode = { 'x' }, -- visual/select mode
    },
  })
end)
```

### Itemgroup Registration (For Organizing Related Items)

```lua
pcall(function()
  local legendary = require('legendary')
  
  legendary.itemgroups({
    {
      itemgroup = 'YankCode',
      description = 'Code yanking utilities',
      icon = '󰆏',
      commands = {
        {
          ':YankCode',
          description = 'Copy selected code with file path and line numbers',
        },
      },
      keymaps = {
        {
          '<leader>yc',
          ':YankCode<CR>',
          description = 'Copy code with context',
          mode = { 'x' },
        },
      },
    },
  })
end)
```

## Common Pitfalls

### ❌ Wrong: Using non-existent `legendary.items()`

```lua
-- This will fail - legendary.items() doesn't exist
legendary.items({
  commands = {...},
  keymaps = {...}
})
```

### ✅ Correct: Use specific functions

```lua
-- This works - use the specific API functions
legendary.commands({...})
legendary.keymaps({...})
```

## Mode Filtering Behavior

**Important distinction:**

- **Commands**: NOT filtered by mode - always visible in picker regardless of current mode
- **Keymaps**: Filtered by mode - only show keymaps available in current mode

This means if a command doesn't appear in the picker, the issue is with registration structure, not mode filtering.

## Best Practices

1. **Wrap in pcall**: Always wrap legendary requires in `pcall()` to avoid errors if plugin is missing
2. **Use icons**: Prefix descriptions with icons for better visual identification (e.g., `'󰆏 YankCode: ...'`)
3. **Flat vs Itemgroups**: Use flat registration for simple cases, itemgroups when organizing many related items
4. **Mode specification**: Be explicit about modes in keymap registration (`mode = { 'n', 'x' }`)

## Reference

- Plugin config example: `plugin/yank-code.lua` (lines 126-142)
- Legendary.nvim docs: https://github.com/mrjones2014/legendary.nvim
