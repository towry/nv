# Implementation Tasks for replace gitsigns.nvim with mini.diff

## Overview
Implement a configuration-only migration from gitsigns.nvim to mini.diff, maintain keymap parity, keep blame via fugitive, and verify via headless load + interactive checks. Follow KSDD: implement tasks in order, verify after each phase.

## Phase 1: Plugin migration and removal
Remove gitsigns and wire in mini.diff config entry points.

- [x] Task 1: Remove gitsigns from plugin manager and requires
  - **Status**: Already completed (no gitsigns references found in codebase)
  - **Requirements**: REQ-004
  - **Design ref**: Architecture → plugins.lua changes; Migration → step 1
  - **Files**: lua/core/plugins.lua

- [x] Task 2: Remove legacy gitsigns config file from runtime
  - **Status**: Already completed (no gitsigns.lua file exists, no <leader>gB mappings)
  - **Requirements**: REQ-003, REQ-004
  - **Design ref**: Architecture → remove/disable gitsigns.lua; Migration → step 1
  - **Files**: lua/core/plugin_configs/gitsigns.lua

- [x] Task 3: Add mini.diff configuration module
  - **Status**: Completed and refined to match design spec
  - **Details**: Updated with view.style, priority=199, delay.text_change=200
  - **Requirements**: REQ-001, REQ-002, REQ-005, REQ-006
  - **Design ref**: Components and Interfaces → mini_diff configuration; Configuration (proposed)
  - **Files**: lua/core/plugin_configs/mini_diff.lua

## Phase 2: Keymap migration (compatibility layer)
Provide parity with prior gitsigns habits while keeping mini.diff defaults.

- [x] Task 4: Navigation compatibility ]c / [c
  - **Status**: Already implemented with diff-mode passthrough
  - **Requirements**: REQ-001, REQ-002
  - **Design ref**: Keymap compatibility layer → Navigation
  - **Files**: lua/core/plugin_configs/mini_diff.lua

- [x] Task 5: Actions <leader>ghs / <leader>ghr
  - **Status**: Already implemented for current line apply/reset
  - **Requirements**: REQ-001, REQ-002, REQ-006
  - **Design ref**: Keymap compatibility layer → Actions
  - **Files**: lua/core/plugin_configs/mini_diff.lua

- [x] Task 6: Textobject ih
  - **Status**: Already implemented for operator/visual mode
  - **Requirements**: REQ-001, REQ-002
  - **Design ref**: Keymap compatibility layer → Textobject
  - **Files**: lua/core/plugin_configs/mini_diff.lua

- [x] Task 7: Overlay toggle mapping
  - **Status**: Already implemented with <leader>gO
  - **Requirements**: REQ-002
  - **Design ref**: Keymap compatibility layer → Overlay
  - **Files**: lua/core/plugin_configs/mini_diff.lua

## Phase 3: Blame continuity and cleanup
Ensure blame workflows remain via fugitive and no broken mappings remain.

- [x] Task 8: Verify blame mapping and remove <leader>gB
  - **Status**: Verified - <leader>gb exists in fugitive.lua, no <leader>gB found
  - **Requirements**: REQ-003
  - **Design ref**: Blame behavior continuity
  - **Files**: lua/core/plugin_configs/fugitive.lua, repo-wide grep

## Phase 4: Testing and verification
Run load tests and manual checks per design.

- [x] Task 9: Headless load test
  - **Status**: PASSED ✅ - Clean exit with no errors or warnings
  - **Command**: `NVIM_APPNAME=neonvim nvim --headless -c 'quit'`
  - **Requirements**: REQ-004.4
  - **Design ref**: Testing Strategy → 1. Headless load
  - **Files**: N/A (execution)

- [x] Task 10: Interactive verification (Git repo)
  - **Status**: PASSED ✅ - All features verified working by user
  - **Requirements**: REQ-001, REQ-002, REQ-005
  - **Design ref**: Testing Strategy → 2. Interactive
  - **Files**: N/A

- [x] Task 11: Interactive verification (non-Git)
  - **Status**: PASSED ✅ - No errors confirmed by user
  - **Requirements**: REQ-001.4, REQ-006.3
  - **Design ref**: Testing Strategy → 3. Non-git
  - **Files**: N/A

- [x] Task 12: Performance sanity
  - **Status**: PASSED ✅ - Performance verified satisfactory by user
  - **Requirements**: REQ-005
  - **Design ref**: Error Handling and Failure Modes; Testing Strategy
  - **Files**: N/A

## Phase 5: Statusline integration (ACTIVE)

- [x] Task 13: Add diff summary component to statusline
  - **Status**: Completed ✅
  - **Requirements**: REQ-007
  - **Design ref**: Statusline integration (ACTIVE)
  - **Files**: lua/core/plugin_configs/statusline.lua
  - **Implementation**:
    1. ✅ Added `section_diff_summary(trunc_width)` function in CUSTOM COMPONENTS section (lines 55-65)
    2. ✅ Function checks truncation (threshold: 75), reads `vim.b.minidiff_summary_string`
    3. ✅ Returns empty string if nil/empty, otherwise returns summary as-is
    4. ✅ Added diff to LEFT section in `build_active_statusline()` alongside git section (line 81, 94)
    5. ✅ Uses MiniStatuslineDevinfo highlight group for consistency
    6. ✅ Headless load test passed (syntax validation)
  - **Verification**: PASSED ✅
    1. ✅ Git-tracked file with changes → diff summary appears in statusline
    2. ✅ Non-Git file → no diff summary, no errors
    3. ✅ Git file with no changes → no diff summary
    4. ✅ Window resize/truncation behavior verified (width < 75)
