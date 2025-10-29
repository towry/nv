# Replace fzf-lua with snacks.nvim Picker Design Document

## Overview

This design document outlines the architectural approach for migrating from fzf-lua to snacks.nvim picker. The migration will be done in phases to ensure stability and maintain user workflow continuity.

**Prerequisites**: 
- snacks.nvim plugin installed and available
- Understanding of current fzf-lua configuration and usage patterns
- Familiarity with snacks.nvim picker API and configuration structure

### Key Objectives
- Replace fzf-lua with snacks.nvim picker while maintaining all existing functionality
- Preserve all current keybindings and user muscle memory
- Implement basic features first (core pickers), then add new custom pickers as enhancements
- Ensure performance is equal or better than current fzf-lua setup
- Clean migration: remove fzf-lua completely, rely on git history for reversion if needed

### Non-goals and Scope Limitations
- Not changing any LSP configuration or behavior (only the picker UI)
- Not modifying core Neovim plugin loading mechanism
- Not implementing custom finders beyond what's needed for feature parity
- Not optimizing or refactoring unrelated configuration files
- No rollback plan or archiving - rely on git history for reversion if needed

---

## Architecture

### System Design

```
┌─────────────────────────────────────────────────────────────────┐
│                         Neovim Core                              │
│  (LSP, Diagnostics, Git, Buffers, Files, etc.)                  │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ Consumes data from
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                  snacks.nvim Picker Layer                        │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐    │
│  │   Built-in     │  │    Custom      │  │   Actions &    │    │
│  │   Sources      │  │   Helpers      │  │   Keymaps      │    │
│  │  (files, grep, │  │  (visual text, │  │  (window pick, │    │
│  │   git, lsp)    │  │   cwd utils)   │  │   navigation)  │    │
│  └────────────────┘  └────────────────┘  └────────────────┘    │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ User interaction via
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Keybinding Layer                              │
│  (lua/core/plugin_configs/snacks_picker.lua + keymaps)          │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **User-Initiated Picker Flow**
   - User presses keybinding (e.g., `<Leader>ff`)
   - Keybinding calls snacks picker function (e.g., `Snacks.picker.files()`)
   - Picker initializes with configured options (cwd, layout, formatters)
   - Finder runs asynchronously to collect items
   - Matcher filters items based on user input
   - Results displayed in picker UI with preview
   - User confirms selection → Action executed (open file, jump to location, etc.)

2. **LSP Integration Flow**
   - User triggers LSP action (e.g., `gd` for definitions)
   - Keybinding calls `Snacks.picker.lsp_definitions()`
   - LSP client queries language server
   - Picker receives LSP response and formats items
   - If single result → Auto-jump, else show picker
   - Preview shows file content at definition location

3. **Custom Action Flow (Window Picker)**
   - User selects file and presses `Ctrl-o`
   - Custom action `files_open_in_window` triggered
   - Window picker UI shows available windows
   - User selects target window
   - File opens in selected window

---

## Components and Interfaces

### Component 1: Core Picker Configuration

**File**: `lua/core/plugin_configs/snacks_picker.lua`

**Responsibilities**:
- Configure global picker settings (window size, borders, layouts, icons)
- Set up default keybindings within pickers
- Register custom actions and formatters
- Enable `vim.ui.select` replacement

**Key Configuration Options**:
```lua
{
  prompt = " ",
  focus = "input",
  show_delay = 1000,
  limit_live = 10000,
  layout = {
    preset = function()
      return vim.o.columns >= 180 and "default" or "vertical"  -- Lowered from 240 for better wide-screen detection
    end,
    cycle = true,
  },
  win = {
    input = { 
      keys = { -- Custom keybindings 
        ["<c-q>"] = "select_all+accept",
        ["<c-u>"] = "half-page-up",
        -- etc.
      }
    }
  },
  matcher = {
    fuzzy = true,
    smartcase = true,
    filename_bonus = true,
  },
  ui_select = true,
}
```

### Component 2: Keybinding Layer

**File**: `lua/core/plugin_configs/snacks_picker_keymaps.lua` (new file)

**Responsibilities**:
- Map all user-facing keybindings to snacks picker functions
- Provide helper functions for visual text extraction and cwd management
- Maintain 1:1 mapping with existing fzf-lua keybindings

**Key Functions**:
- `get_visual_selection()` - Extract visual selection text
- `get_root_dir()` - Get current working directory
- Keymaps for files, buffers, grep, git, LSP, utilities

### Component 3: Custom Actions

**File**: `lua/core/plugin_configs/snacks_picker_actions.lua` (new file)

**Responsibilities**:
- Implement custom actions not provided by snacks.nvim
- Window picker integration for `Ctrl-o` behavior
- Custom buffer/file opening logic

**Key Actions**:
- `files_open_in_window` - Open file in selected window
- `buffers_open_in_window` - Open buffer in selected window
- Custom grep actions (if needed)

### Component 4: Plugin Registration

**File**: `lua/core/plugins.lua`

**Changes**:
- Remove or comment out fzf-lua plugin registration
- Ensure snacks.nvim is properly registered with picker module enabled
- Handle lazy loading appropriately

---

## Data Models

### Configuration

**Global Picker Settings**:
- `prompt`: String - Picker prompt symbol (default: " ")
- `focus`: "input"|"list" - Initial focus target (default: "input")
- `show_delay`: Number - Delay before showing picker (default: 1000ms)
- `limit_live`: Number - Max items for live searches (default: 10000)
- `layout.preset`: Function|String - Layout selection logic
- `win.input.keys`: Table - Custom keybindings within picker
- `matcher.fuzzy`: Boolean - Enable fuzzy matching (default: true)
- `ui_select`: Boolean - Replace vim.ui.select (default: true)

**Picker-Specific Options** (passed to each picker call):
- `cwd`: String - Working directory for search
- `query`: String - Initial search query
- `search`: String - Pre-filled search text
- `layout`: String|Table - Override global layout
- `preview`: Boolean - Show/hide preview
- `confirm`: String|Function - Confirm action

### Helper Function Signatures

```lua
-- Get visual selection text
---@return string
function get_visual_selection() end

-- Get current working directory
---@return string
function get_root_dir() end

-- Check if executable exists
---@param cmd string
---@return boolean
function is_executable(cmd) end
```

---

## Implementation Details

### Proof of Concept (PoC)

#### Experiment Goals
- Verify snacks.nvim picker performance with large file sets (10k+ files)
- Test custom action implementation for window picker
- Validate layout configuration matches fzf-lua visual appearance
- Confirm LSP integration works with auto-jump for single results

#### Validation Steps
1. Install snacks.nvim in a test Neovim config
2. Configure basic file picker with custom layout matching current fzf-lua setup
3. Test with large repository (e.g., neovim/neovim source)
4. Implement and test window picker custom action
5. Test LSP definitions with single and multiple results

#### Findings
- ✅ snacks.nvim picker is fast and responsive with large file sets
- ✅ Layout system is flexible; can match fzf-lua appearance
- ✅ Custom actions can be implemented via `actions` table
- ⚠️ Window picker needs custom implementation (no built-in equivalent)
- ✅ LSP integration supports `auto_confirm` for single results

#### Next Actions
- Implement window picker helper (can use `vim.ui.select` for window selection)
- Finalize layout configuration for horizontal/vertical adaptive behavior
- Test all keybindings end-to-end
- Document any differences from fzf-lua behavior

### Key Implementation Patterns

#### 1. Visual Selection Helper

```lua
local function get_visual_selection()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "" then
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local lines = vim.fn.getline(start_pos[2], end_pos[2])
    if #lines == 0 then return "" end
    
    if #lines == 1 then
      return string.sub(lines[1], start_pos[3], end_pos[3])
    else
      lines[1] = string.sub(lines[1], start_pos[3])
      lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
      return table.concat(lines, "\n")
    end
  end
  return ""
end
```

#### 2. Adaptive Layout Configuration

```lua
layout = {
  preset = function()
    return vim.o.columns >= 240 and "default" or "vertical"
  end,
  -- Override specific layout properties if needed
  config = function(layout)
    if layout.preset == "default" then
      layout.layout.width = 0.85
      layout.layout.height = 0.95
    end
  end,
}
```

#### 3. Window Picker Action

```lua
local function pick_window_and_open(selected, opts)
  -- Get list of valid windows
  local windows = vim.api.nvim_list_wins()
  local valid_wins = vim.tbl_filter(function(win)
    local buf = vim.api.nvim_win_get_buf(win)
    local bt = vim.bo[buf].buftype
    return bt ~= "nofile" and vim.api.nvim_win_get_config(win).relative == ""
  end, windows)
  
  if #valid_wins == 1 then
    -- Only one window, just open there
    vim.api.nvim_set_current_win(valid_wins[1])
    require("snacks.picker.actions").jump(selected, opts)
    return
  end
  
  -- Use vim.ui.select to pick window
  vim.ui.select(valid_wins, {
    prompt = "Select window:",
    format_item = function(win)
      local buf = vim.api.nvim_win_get_buf(win)
      local name = vim.api.nvim_buf_get_name(buf)
      return string.format("Win %d: %s", win, vim.fn.fnamemodify(name, ":t"))
    end,
  }, function(choice)
    if choice then
      vim.api.nvim_set_current_win(choice)
      require("snacks.picker.actions").jump(selected, opts)
    end
  end)
end
```

### Performance Considerations

1. **Large File Sets**
   - Use `limit_live` to cap results during live searches
   - Leverage snacks.nvim's async finder architecture
   - Use `show_delay` to avoid flicker on fast searches

2. **Live Grep Performance**
   - Rely on ripgrep for fast searching
   - Use `live = true` only for grep/search pickers
   - Static file lists don't need live mode

3. **Matcher Performance**
   - Enable `fuzzy` matching for better UX
   - Use `filename_bonus` for better file matching
   - Disable `frecency` initially (can enable later if needed)

### Security Considerations

1. **Command Injection**
   - All user input to grep/find commands is properly escaped by snacks.nvim
   - No custom shell command construction needed

2. **File Access**
   - Picker respects Neovim's file permissions
   - No elevation of privileges required

---

## Error Handling

### Error Scenarios

1. **Missing Dependencies**
   - `ripgrep` not found: Show notification suggesting installation or fallback to grep
   - `git` not found: Disable git pickers gracefully
   - `fd` not found: Fallback to find command

2. **LSP Errors**
   - No LSP attached: Show notification "No LSP client attached"
   - LSP timeout: Show notification "LSP request timed out"
   - Invalid LSP response: Log error and close picker

3. **File Access Errors**
   - Permission denied: Show notification and skip file
   - File not found: Remove from results
   - Binary file preview: Show message "Binary file, preview disabled"

### Error Handling Implementation

```lua
-- Example: Graceful degradation for missing ripgrep
vim.keymap.set("n", "<Leader>fg", function()
  if vim.fn.executable("rg") == 1 then
    require("snacks").picker.grep({ live = true, cwd = vim.fn.getcwd() })
  else
    vim.notify("ripgrep not found. Please install ripgrep for live grep.", vim.log.levels.WARN)
  end
end, { desc = "Live grep" })
```

---

## Testing Strategy

### Manual Testing Checklist

1. **File Navigation**
   - [ ] File picker shows files correctly
   - [ ] Buffer picker shows open buffers
   - [ ] Recent files shows only CWD files
   - [ ] Resume works correctly
   - [ ] Config file picker works

2. **Grep Functionality**
   - [ ] Live grep shows results in real-time
   - [ ] Visual selection grep pre-fills search
   - [ ] Current buffer grep works
   - [ ] Grep word under cursor works

3. **Git Integration**
   - [ ] Git branches picker works
   - [ ] Git commits (repo and file) work
   - [ ] Git status picker works
   - [ ] Branch checkout works

4. **LSP Integration**
   - [ ] Go to definition works (single result auto-jumps)
   - [ ] References picker works
   - [ ] Implementations picker works
   - [ ] Document/workspace symbols work
   - [ ] Diagnostics picker works

5. **Utilities**
   - [ ] Quickfix, jumplist, marks pickers work
   - [ ] Registers, command history work
   - [ ] Help, keymaps, man pages work
   - [ ] vim.ui.select replacement works

6. **Custom Actions**
   - [ ] Window picker (Ctrl-o) works
   - [ ] Select all (Ctrl-q) works
   - [ ] Preview scroll (Ctrl-f/b) works

### Integration Testing

1. **Plugin Interactions**
   - Test with which-key for keymap display
   - Test with LSP clients (lua_ls, ts_ls, etc.)
   - Test with Git fugitive integration

2. **Performance Testing**
   - Test file picker with 10,000+ files
   - Test live grep with large codebase
   - Monitor memory usage during long sessions

---

## Migration and Rollout

### Migration Strategy

**Phase 1: Basic Implementation**
1. Remove fzf-lua plugin registration from `plugins.lua`
2. Delete fzf-lua config files (`lua/core/plugin_configs/fzf*.lua`)
3. Create new `lua/core/plugin_configs/snacks.lua` with picker configuration
4. Implement all basic pickers (files, buffers, grep, git, LSP, utilities)
5. Set up all existing keybindings to use snacks.nvim pickers
6. Test all basic functionality thoroughly

**Phase 2: New Custom Pickers (Enhancements)**
1. Add new pickers not available in fzf-lua:
   - `Snacks.picker.explorer()` - File explorer with tree view
   - `Snacks.picker.projects()` - Project management
   - `Snacks.picker.undo()` - Undo history with diff preview
   - `Snacks.picker.zoxide()` - Directory navigation (if zoxide installed)
2. Create keybindings for new pickers
3. Document new features and usage
4. Test new pickers and integrate into workflow

### Reversion Strategy

If migration needs to be reverted:
1. Use `git revert` or `git reset` to restore previous state
2. Reinstall plugins with `:PackInstall` or package manager
3. Restart Neovim

No rollback plan or archived files needed - git history is sufficient.

---

## Research and API Documentation

### snacks.nvim Picker Key APIs

**Documentation URL**: https://github.com/folke/snacks.nvim/blob/main/docs/picker.md

**Core Picker Functions** (all under `Snacks.picker.*`):
- `files(opts)` - File picker
- `buffers(opts)` - Buffer picker
- `recent(opts)` - Recent files
- `grep(opts)` - Grep search (supports `live = true`)
- `grep_word(opts)` - Grep word under cursor
- `git_branches(opts)` - Git branches
- `git_log(opts)` - Git commits (repo)
- `git_log_file(opts)` - Git commits (file)
- `git_status(opts)` - Git status
- `lsp_definitions(opts)` - LSP definitions (supports `auto_confirm = true`)
- `lsp_references(opts)` - LSP references
- `lsp_implementations(opts)` - LSP implementations
- `lsp_type_definitions(opts)` - LSP type definitions
- `lsp_symbols(opts)` - LSP document symbols
- `lsp_workspace_symbols(opts)` - LSP workspace symbols
- `diagnostics(opts)` - Diagnostics
- `diagnostics_buffer(opts)` - Buffer diagnostics
- `quickfix(opts)` - Quickfix list
- `jumps(opts)` - Jumplist
- `marks(opts)` - Marks
- `registers(opts)` - Registers
- `command_history(opts)` - Command history
- `commands(opts)` - Commands
- `help(opts)` - Help tags
- `keymaps(opts)` - Keymaps
- `man(opts)` - Man pages
- `resume(opts)` - Resume last picker
- `zoxide(opts)` - **Built-in zoxide integration!**
- `explorer(opts)` - **File explorer with tree view**
- `projects(opts)` - **Project management**
- `undo(opts)` - **Undo history with diff**

**Layout Presets**:
- `default` - Horizontal layout (preview on right)
- `vertical` - Vertical layout (preview on bottom)
- `ivy` - Bottom-up layout
- `sidebar` - Sidebar layout
- `telescope` - Telescope-style layout

**Common Options**:
- `cwd` - Working directory
- `search` / `query` - Initial search text
- `layout` - Layout preset or custom config
- `preview` - Preview configuration
- `confirm` - Confirm action (function or action name)
- `live` - Enable live mode
- `auto_confirm` - Auto-confirm if only one result

### Important Configuration Notes

1. **Keybindings**: Defined under `win.input.keys` and `win.list.keys`
2. **Actions**: Can be custom functions or action name strings
3. **Formatters**: Control how items are displayed (e.g., `filename_first`)
4. **Matcher**: Fuzzy matching with smartcase, filename bonus, etc.
5. **Filter**: Pre-filter items based on cwd, buffer, paths, etc.

---

## Troubleshooting and Implementation Notes

### Plugin Loading with vim.pack

**Critical Discovery**: Plugins installed via `vim.pack.add()` are stored in:
```
~/.local/share/nvim/site/pack/core/opt/
```

NOT in `~/.config/nvim/pack/plugins/start/`

**Loading Behavior**:
- All plugins are installed to the `opt/` directory (lazy-loaded)
- Plugins in `opt/` **require explicit `packadd`** before they can be required
- Example: `vim.cmd('packadd snacks.nvim')` must be called before `require('snacks')`

**Common Issue**: If you see "plugin not found" errors:
1. Check if the plugin exists in `~/.local/share/nvim/site/pack/core/opt/`
2. Verify the plugin has a `lua/` directory with actual module files (not just `.git/`)
3. Add `vim.cmd('packadd plugin-name')` in `plugins.lua` before requiring it

**Example Pattern** (from `lua/core/plugins.lua`):
```lua
-- Eager-load snacks.nvim so snacks.* configs can initialize
pcall(function()
  vim.cmd('packadd snacks.nvim')
end)

-- Now safe to require in config files
pcall(require, 'core.plugin_configs.snacks')
```

### Grep Functionality with snacks.nvim

**Important**: The `live` parameter behavior differs from fzf-lua:

- `live = true` (default for `grep()`): Searches **as you type** in real-time
- `live = false` (default for `grep_word()`): Requires a pre-filled `search` parameter

**Static grep** (prompt first, then search) **does not exist** in snacks.nvim's default API. Instead:
- Use `live = true` for interactive grep (recommended)
- Or use `vim.ui.input()` to prompt for search term, then call `grep({ search = term, live = false })`

**Recommendation**: Use `live = true` for all grep operations - it provides better UX and matches modern picker behavior.

**Example**:
```lua
-- ✅ Works: Live grep
snacks.picker.grep({ live = true, cwd = vim.fn.getcwd() })

-- ❌ Doesn't work: Opens picker but nothing happens when typing
snacks.picker.grep({ live = false, cwd = vim.fn.getcwd() })

-- ✅ Works: Pre-filled search
snacks.picker.grep({ live = false, search = "my_search_term" })
```