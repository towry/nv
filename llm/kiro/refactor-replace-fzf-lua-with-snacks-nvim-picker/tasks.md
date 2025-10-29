# Implementation Tasks for replace fzf-lua with snacks.nvim picker

## Overview

This document outlines the implementation tasks for migrating from fzf-lua to snacks.nvim picker. The migration follows a phased approach: Phase 1 implements basic feature parity with existing fzf-lua functionality, Phase 2 adds new enhancements available in snacks.nvim.

**Migration Strategy**: Clean removal of fzf-lua, no archiving. Git history provides reversion capability if needed.

---

## Phase 1: Basic Migration (Feature Parity)

This phase focuses on achieving complete feature parity with the existing fzf-lua setup. All core pickers, keybindings, and functionality must work exactly as before.

### P1.1: Remove fzf-lua Plugin

- **Prompt**: Remove the fzf-lua plugin registration from `lua/core/plugins.lua`. Look for any `vim.pack.add()` or similar calls that load fzf-lua, and remove them completely. Ensure no errors occur when the plugin is removed.

- **Requirements**: REQ-011, REQ-012

- **Design ref**: Section: Migration Strategy (Phase 1, Step 1)

- **Files**: 
  - `lua/core/plugins.lua`

- **Verification**: Run `NVIM_APPNAME=neonvim nvim --headless -c 'quit'` and ensure no errors related to fzf-lua appear.

---

### P1.2: Add snacks.nvim Plugin

- **Prompt**: Add snacks.nvim plugin registration to `lua/core/plugins.lua`. Use the native `vim.pack.add()` system. Ensure the picker module is enabled in the snacks configuration. Refer to the snacks.nvim documentation at https://github.com/folke/snacks.nvim for proper setup.

- **Requirements**: REQ-011, REQ-012

- **Design ref**: Section: Component 4 (Plugin Registration)

- **Files**:
  - `lua/core/plugins.lua`

- **Verification**: Run `NVIM_APPNAME=neonvim nvim --headless -c "lua print(require('snacks').picker)" -c 'quit'` and ensure snacks.nvim loads without errors.

---

### P1.3: Create snacks Picker Configuration

- **Prompt**: Create a new file `lua/core/plugin_configs/snacks.lua` that configures the snacks.nvim picker. 

**Configuration Requirements**:
1. Set global picker settings: prompt=" ", focus="input", show_delay=1000, limit_live=10000
2. Configure adaptive layout: use "default" preset for columns >= 240, else "vertical"
3. Set window dimensions: 85% width, 95% height
4. Configure preview: right side at 45% width (horizontal), bottom at 40% height (vertical)
5. Set up custom keybindings within picker:
   - `<c-q>`: select_all+accept
   - `<c-u>`: half-page-up
   - `<c-d>`: half-page-down
   - `<c-f>`: preview_scroll_down
   - `<c-b>`: preview_scroll_up
   - `<Tab>`: toggle+down
   - `<S-Tab>`: toggle+up
   - `<c-o>`: Custom window picker action (implement in P1.4+)
6. Configure matcher: fuzzy=true, smartcase=true, filename_bonus=true
7. Enable vim.ui.select replacement: ui_select=true

**Reference API from design.md**: See "Component 1: Core Picker Configuration" and "Research and API Documentation" sections.

- **Requirements**: REQ-006, REQ-007, REQ-008, REQ-010

- **Design ref**: Sections: Component 1 (Core Picker Configuration), Implementation Details (Adaptive Layout Configuration)

- **Files**:
  - `lua/core/plugin_configs/snacks.lua` (create new)

- **Verification**: 
  1. Run `NVIM_APPNAME=neonvim nvim` and execute `:lua require('snacks').picker.files()`
  2. Verify window size matches 85%x95%
  3. Test layout switches between horizontal/vertical based on window width
  4. Test keybindings work within picker

---

### P1.4: Implement Core Pickers (Files, Buffers, Grep)

- **Prompt**: Create keybindings for core file and buffer pickers in `lua/core/keymaps.lua` (or create a dedicated `lua/core/plugin_configs/snacks_picker_keymaps.lua` file).

**Keybindings to implement**:
1. `<Leader>ff`: `Snacks.picker.files()` with cwd=current directory
2. `<Leader>fB`: `Snacks.picker.buffers()` with filename_first formatting
3. `<Leader>fo`: `Snacks.picker.recent()` filtered to CWD only
4. `<Leader>fl` and `<Leader>f<CR>`: `Snacks.picker.resume()`
5. `,` (localleader): `Snacks.picker.recent()` (recent files and buffers from session)
6. `<Leader>fXa`: `Snacks.picker.files({ cwd = vim.fn.stdpath("config") })`
7. `<Leader>fg`: `Snacks.picker.grep({ live = true })` - live grep in CWD
8. `<Leader>fs`: `Snacks.picker.grep()` - static grep
9. `<Leader>fg` (visual mode): Extract visual selection and pass to grep as initial query
10. `<Leader>fc`: `Snacks.picker.grep_word()` - grep word under cursor
11. `<Leader>fb`: `Snacks.picker.grep_buffer()` - grep in current buffer
12. `<Leader>f/`: `Snacks.picker.grep({ live = true, filter = { buf = 0 } })` - live grep in buffer

**Helper function needed**: `get_visual_selection()` - extract visual selection text (see design.md for implementation).

**Graceful degradation**: Check if `ripgrep` is available before running grep pickers. Show notification if missing.

- **Requirements**: REQ-001, REQ-002, REQ-010

- **Design ref**: Sections: Component 2 (Keybinding Layer), Implementation Details (Visual Selection Helper, Performance Considerations)

- **Files**:
  - `lua/core/keymaps.lua` OR `lua/core/plugin_configs/snacks_picker_keymaps.lua` (create new)

- **Verification**:
  1. Test each keybinding manually
  2. Verify visual selection grep pre-fills search query
  3. Test with large repository (10k+ files) for performance
  4. Test ripgrep missing scenario

---

### P1.5: Implement Git Pickers

- **Prompt**: Add Git-related picker keybindings to the keymaps file.

**Keybindings to implement**:
1. `<Leader>gfb`: `Snacks.picker.git_branches()` - Git branches with checkout action
2. `<Leader>gfc`: `Snacks.picker.git_log()` - Repository-wide Git commits
3. `<Leader>gfC`: `Snacks.picker.git_log_file()` - Git commits for current file
4. `<Leader>gfs`: `Snacks.picker.git_status()` - Git status with changed files

**Graceful degradation**: Check if Git is available and if CWD is a Git repository. Show appropriate notification if not.

- **Requirements**: REQ-003

- **Design ref**: Section: Component 2 (Keybinding Layer), Error Handling

- **Files**:
  - `lua/core/keymaps.lua` OR `lua/core/plugin_configs/snacks_picker_keymaps.lua`

- **Verification**:
  1. Test in Git repository - all pickers should work
  2. Test in non-Git directory - should show graceful error
  3. Test branch checkout functionality
  4. Verify commit previews show diffs

---

### P1.6: Implement LSP Pickers

- **Prompt**: Add LSP-related picker keybindings to the keymaps file.

**Keybindings to implement**:
1. `gd`: `Snacks.picker.lsp_definitions({ auto_confirm = true })` - Auto-jump if single result
2. `grr`: `Snacks.picker.lsp_references()` - LSP references
3. `gri`: `Snacks.picker.lsp_implementations()` - LSP implementations
4. `gy`: `Snacks.picker.lsp_type_definitions()` - LSP type definitions
5. `<Leader>ls`: `Snacks.picker.lsp_symbols()` - Document symbols
6. `<Leader>lS` and `<Leader>lG`: `Snacks.picker.lsp_workspace_symbols()` - Workspace symbols
7. `<Leader>lD`: `Snacks.picker.diagnostics_buffer()` - Document diagnostics

**Graceful degradation**: Check if LSP client is attached to buffer. Show notification "No LSP client attached" if not.

- **Requirements**: REQ-004

- **Design ref**: Sections: Data Flow (LSP Integration Flow), Component 2 (Keybinding Layer), Error Handling

- **Files**:
  - `lua/core/keymaps.lua` OR `lua/core/plugin_configs/snacks_picker_keymaps.lua`

- **Verification**:
  1. Test in file with LSP attached (e.g., Lua file with lua_ls)
  2. Verify `gd` auto-jumps when single definition
  3. Verify `gd` shows picker when multiple definitions
  4. Test in file without LSP - should show graceful error
  5. Test all LSP pickers with various symbols/references

---

### P1.7: Implement Utility Pickers

- **Prompt**: Add utility picker keybindings to the keymaps file.

**Keybindings to implement**:
1. `<Leader>fq`: `Snacks.picker.quickfix()` - Quickfix list
2. `<Leader>fj`: `Snacks.picker.jumps()` - Jumplist
3. `<Leader>f'`: `Snacks.picker.marks()` - Marks
4. `<Leader>fr`: `Snacks.picker.registers()` - Registers with preview
5. `<Leader>f;`: `Snacks.picker.command_history()` - Command history
6. `<Leader>f:`: `Snacks.picker.commands()` - Available commands
7. `<Leader>fh`: `Snacks.picker.help()` - Help tags
8. `<Leader>fk`: `Snacks.picker.keymaps()` - Keymaps
9. `<Leader>fm`: `Snacks.picker.man()` - Man pages
10. `<Leader>f.`: Show main picker selector (picker of pickers)

- **Requirements**: REQ-005

- **Design ref**: Section: Component 2 (Keybinding Layer)

- **Files**:
  - `lua/core/keymaps.lua` OR `lua/core/plugin_configs/snacks_picker_keymaps.lua`

- **Verification**:
  1. Test each picker manually
  2. Verify registers show preview correctly
  3. Verify help tags search works
  4. Test main picker selector shows all available pickers

---

### P1.8: Set Up Keybindings in keymaps.lua

- **Prompt**: If keybindings were created in a separate file (`snacks_picker_keymaps.lua`), ensure that file is loaded from `lua/core/keymaps.lua` or another appropriate location. If keybindings were added directly to `keymaps.lua`, ensure they are properly organized and commented.

**Verify all keybindings are properly registered**:
- Core pickers (P1.4)
- Git pickers (P1.5)
- LSP pickers (P1.6)
- Utility pickers (P1.7)

**Ensure pcall wrapper**: Wrap all `require('snacks')` calls in `pcall` to avoid errors if plugin not loaded.

- **Requirements**: REQ-001 through REQ-005, REQ-011

- **Design ref**: Sections: Component 2 (Keybinding Layer), Architecture (Keybinding Layer)

- **Files**:
  - `lua/core/keymaps.lua`
  - `lua/core/plugin_configs/snacks_picker_keymaps.lua` (if created)

- **Verification**:
  1. Run `NVIM_APPNAME=neonvim nvim --headless -c 'quit'` - no errors
  2. Open Neovim and test random keybindings from each category
  3. Verify pcall wrappers prevent errors when snacks not loaded

---

### P1.9: Update which-key Descriptions

- **Prompt**: Update which-key descriptions in `lua/core/plugin_configs/which_key.lua` to reflect the new snacks.nvim picker keybindings. Ensure all picker-related keybindings have clear, descriptive labels.

**Key groups to update**:
- `<Leader>f` - File/Finder pickers
- `<Leader>gf` - Git pickers
- `<Leader>l` - LSP pickers (if using which-key for LSP)

**Ensure descriptions match the actual picker behavior**.

- **Requirements**: REQ-001 through REQ-005

- **Design ref**: Section: Component 2 (Keybinding Layer)

- **Files**:
  - `lua/core/plugin_configs/which_key.lua`

- **Verification**:
  1. Press `<Leader>f` and verify which-key shows updated descriptions
  2. Press `<Leader>gf` and verify Git picker descriptions
  3. Verify all descriptions are clear and accurate

---

### P1.10: Remove Old fzf-lua Config Files

- **Prompt**: Delete all fzf-lua configuration files from the config directory.

**Files to remove**:
- `lua/core/plugin_configs/fzf.lua`
- `lua/core/plugin_configs/fzf_keymaps.lua`
- `lua/core/plugin_configs/fzf_actions.lua`
- `lua/core/plugin_configs/fzf_pickers.lua`
- Any other fzf-lua related configuration files

**Ensure no other files reference these removed files**. Search the codebase for `require.*fzf` to find any remaining references.

- **Requirements**: REQ-012

- **Design ref**: Section: Migration Strategy (Phase 1, Step 2)

- **Files**:
  - `lua/core/plugin_configs/fzf.lua` (delete)
  - `lua/core/plugin_configs/fzf_keymaps.lua` (delete)
  - `lua/core/plugin_configs/fzf_actions.lua` (delete)
  - `lua/core/plugin_configs/fzf_pickers.lua` (delete)

- **Verification**:
  1. Run `fd fzf lua/` - should return no results
  2. Run `rg "require.*fzf" lua/` - should return no results (or only comments)
  3. Run `NVIM_APPNAME=neonvim nvim --headless -c 'quit'` - no errors
  4. Open Neovim and test all pickers - everything should work

---

## Phase 2: Enhancements (New Features)

This phase adds new pickers and features that were not available in fzf-lua. These are enhancements that improve the overall user experience.

### P2.1: Add New Custom Pickers (Explorer, Projects, Undo, Zoxide)

- **Prompt**: Add keybindings for new snacks.nvim pickers that were not available in fzf-lua.

**New pickers to implement**:
1. `<Leader>fe`: `Snacks.picker.explorer()` - File explorer with tree view
2. `<Leader>fp`: `Snacks.picker.projects()` - Project management
3. `<Leader>fu`: `Snacks.picker.undo()` - Undo history with diff preview
4. `<Leader>fz`: `Snacks.picker.zoxide()` - Directory navigation (check if zoxide is installed first)

**Graceful degradation**: Check if zoxide is installed before enabling zoxide picker.

- **Requirements**: REQ-009, REQ-012

- **Design ref**: Section: Migration Strategy (Phase 2, Step 1)

- **Files**:
  - `lua/core/keymaps.lua` OR `lua/core/plugin_configs/snacks_picker_keymaps.lua`

- **Verification**:
  1. Test each new picker manually
  2. Verify explorer shows tree view correctly
  3. Test undo picker shows diff previews
  4. Test zoxide picker (if zoxide installed)

---

### P2.2: Implement Window Picker Action (Ctrl-o)

- **Prompt**: Implement the custom window picker action for `Ctrl-o` keybinding within the picker. This should allow selecting a file/buffer and opening it in a specific window.

**Implementation**:
1. Create a helper function `pick_window_and_open(selected, opts)` (see design.md for reference implementation)
2. Register this action in the snacks picker configuration under `win.input.keys["<c-o>"]`
3. The action should:
   - Get list of valid windows (exclude nofile buffers, floating windows)
   - If only one window, open there directly
   - If multiple windows, use `vim.ui.select` to pick target window
   - Open selected file/buffer in chosen window

- **Requirements**: REQ-007

- **Design ref**: Sections: Component 3 (Custom Actions), Implementation Details (Window Picker Action)

- **Files**:
  - `lua/core/plugin_configs/snacks.lua`
  - `lua/core/plugin_configs/snacks_picker_actions.lua` (create new, optional)

- **Verification**:
  1. Split window into 2+ panes
  2. Open file picker
  3. Select file and press `<c-o>`
  4. Verify window picker appears
  5. Select target window
  6. Verify file opens in chosen window

---

### P2.3: Performance Optimizations

- **Prompt**: Review and optimize picker performance settings based on actual usage.

**Optimizations to consider**:
1. Adjust `limit_live` if needed for very large repositories
2. Fine-tune `show_delay` for optimal responsiveness
3. Enable frecency sorting if desired: `matcher.frecency = true`
4. Adjust preview line limits for large files
5. Monitor and optimize any slow pickers identified during usage

**Benchmark performance**:
- File picker with 10,000+ files
- Live grep in large codebase
- LSP symbols in large file

- **Requirements**: REQ-010

- **Design ref**: Section: Performance Considerations

- **Files**:
  - `lua/core/plugin_configs/snacks.lua`

- **Verification**:
  1. Test file picker in neovim/neovim repository (or similar large repo)
  2. Measure time to first result display
  3. Verify results appear within 500ms for file picker
  4. Verify live grep updates within 200ms

---

### P2.4: UI Polish and Custom Formatters

- **Prompt**: Add any custom formatters, icons, or UI enhancements to improve the picker appearance.

**Enhancements to consider**:
1. Custom icons for different file types
2. Custom formatters for specific picker types (e.g., filename_first for buffers)
3. Custom highlights for matched text
4. Custom preview configurations for specific file types (e.g., binary file handling)
5. Custom title/header formatting

**Reference**: See snacks.nvim documentation for formatter and icon customization options.

- **Requirements**: REQ-006

- **Design ref**: Sections: Component 1 (Core Picker Configuration), Research and API Documentation

- **Files**:
  - `lua/core/plugin_configs/snacks.lua`

- **Verification**:
  1. Open various pickers and verify UI looks polished
  2. Test custom icons display correctly
  3. Verify formatters improve readability
  4. Test preview handles edge cases gracefully (binary files, large files, etc.)