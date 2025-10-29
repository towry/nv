# Kiro Spec Control Board

**Project**: replace fzf-lua with snacks.nvim picker
**Created**: 2025-10-25T13:56:08.989854+00:00
**Owner**: towry

**Spec files status** (one of: ready, draft, empty):

- requirements.md: ready (approved 2025-10-25)
- design.md: ready (approved 2025-10-25)
- tasks.md: ready (approved 2025-10-26, Phase 1 completed 2025-10-26)

---

# Critical Rules

- Make sure **Spec files status** is up to date
- **Never proceed without user approval** for any phase transition
- **Always ask questions** when requirements are unclear
- **Present options** for user to choose from rather than assuming intent
- **Only edit code** when explicitly requested or after plan approval
- **Keep user decisions documented**: update Session Notebook -> Decisions with the new decisions that user made, like user want to tweak the design to use X instead of Y.

# Session Notebook

## Decisions

- **2025-10-25**: User approved requirements.md and design.md specifications
- **2025-10-25**: Phased migration approach confirmed - Phase 1 (basic functionality) then Phase 2 (enhancements)
- **2025-10-25**: Clean migration strategy - remove fzf-lua completely, rely on git history for reversion
- **2025-10-26**: User approved tasks.md and initiated Phase 1 implementation
- **2025-10-26**: Phase 1 implementation completed - All 10 tasks (P1.1 through P1.10) successfully implemented and verified
- **2025-10-26**: Grep functionality fixed - Changed `<Leader>fs` from `live = false` to `live = true` (Option 3)
- **2025-10-26**: Layout improvement - Lowered wide-screen threshold from 240 to 180 columns for better horizontal layout detection (Option 1)

## Questions

<!-- List of questions asked to the user and their answers -->

## Risks

<!-- List of identified risks and mitigation strategies -->

## Findings

- **2025-10-26 Phase 1 Implementation**:
  - Successfully migrated from fzf-lua to snacks.nvim picker
  - All keybindings preserved with 1:1 mapping from fzf-lua to snacks.nvim
  - Graceful degradation implemented for missing dependencies (ripgrep, git, LSP)
  - Configuration loads without errors in headless mode
  - Files created: `lua/core/plugin_configs/snacks.lua`, `lua/core/plugin_configs/snacks_picker.lua`
  - Files deleted: `fzf.lua`, `fzf_keymaps.lua`, `fzf_actions.lua`, `fzf_pickers.lua`

- **2025-10-26 Troubleshooting Session**:
  - **Plugin Loading Discovery**: 
    - Plugins via `vim.pack.add()` install to `~/.local/share/nvim/site/pack/core/opt/`
    - NOT to `~/.config/nvim/pack/plugins/start/` (this directory is unused)
    - All plugins are lazy-loaded from `opt/` directory
    - Require explicit `packadd` before `require()` calls
  - **snacks.nvim Installation Issue**:
    - Initial installation was incomplete (only `.git/` directory, no Lua files)
    - Fixed by removing broken installation and re-cloning
    - Added `vim.cmd('packadd snacks.nvim')` in `plugins.lua` (similar to mini.nvim pattern)
  - **Grep Functionality Discovery**:
    - `live = true`: Searches as you type (default for `grep()`) ✅
    - `live = false`: Requires pre-filled `search` parameter (default for `grep_word()`)
    - Static grep (prompt first, then search) doesn't exist in snacks.nvim API
    - Solution: Changed `<Leader>fs` from `live = false` to `live = true`
  - **Old Plugin Cleanup Needed**:
    - `fzf-lua` still exists in `~/.local/share/nvim/site/pack/core/opt/fzf-lua/`
    - Should be removed as part of Phase 1 completion
  - which-key descriptions updated for all picker keybindings
  - All Phase 1 requirements (REQ-001 through REQ-012) satisfied

