# Requirements Document

## Introduction

Goal: Replace lewis6991/gitsigns.nvim with echasnovski/mini.diff in this Neovim configuration while preserving essential workflows for working with Git diff hunks.

Scope: Configuration-only migration (plugin list + per-plugin config + keymaps). No changes to business logic beyond replacing gitsigns functionality. Keep overall UX minimal and consistent with existing key habits.

Out of Scope: Implementing full Git client features (unstage hunks, etc.). mini.diff intentionally does not provide all gitsigns features.

## Requirements

### REQ-001: Hunk visualization and basic operations via mini.diff

User Story: As a developer, I want to see and interact with diff hunks inline, so that I can quickly review and stage/reset changes without leaving the buffer.

Acceptance Criteria
1. GIVEN a file inside a Git repository, WHEN editing, THEN hunk visualization SHALL be enabled by mini.diff without errors.
2. Hunk visualization style SHALL default to colored line numbers ("number" view) when line numbers are enabled; otherwise fall back to signs, aligning with mini.diff defaults.
3. The following operations SHALL be available using mini.diff mappings or equivalent:
   - Apply (stage) hunks in a visual/operator region.
   - Reset hunks in a visual/operator region.
   - Navigate to first/previous/next/last hunk.
   - Select "hunk range under cursor" as a textobject.
4. Non-Git buffers/files SHALL NOT error and SHALL avoid enabling Git-backed features (graceful no-op).

### REQ-002: Keymap parity and compat layer

User Story: As a long-time user of the current config, I want familiar keymaps to keep working, so that my muscle memory remains effective after the migration.

Acceptance Criteria
1. Navigation: `]c` and `[c` SHALL navigate to next/previous hunk, respectively (compat with prior gitsigns mappings). It is acceptable to also enable mini.diff defaults `]h`/`[h`.
2. Actions: `<leader>ghs` SHALL stage/apply the current hunk (or current line when applicable). `<leader>ghr` SHALL reset the current hunk (or current line when applicable).
3. Textobject: `ih` in operator/visual mode SHALL select the hunk range under cursor, preserving prior usage; mini.diff default textobject `gh` MAY also remain available.
4. Overlay: Provide a mapping to toggle mini.diff overlay view (e.g., `<leader>gO`); exact key can be finalized during design.

### REQ-003: Blame behavior continuity using existing tooling

User Story: As a developer, I want an integrated way to view line/file blame, so that I can attribute changes when needed.

Acceptance Criteria
1. Since mini.diff does not provide inline blame, the configuration SHALL rely on existing fugitive mapping `<leader>gb` (`:Git blame`).
2. The previous gitsigns-only mapping `<leader>gB` (toggle_current_line_blame) SHALL be removed or repurposed; no broken mappings SHALL remain.

### REQ-004: Plugin management and config hygiene

User Story: As a maintainer, I want clean plugin state, so that startup remains fast and error-free.

Acceptance Criteria
1. `lewis6991/gitsigns.nvim` SHALL be removed from plugin management and not loaded.
2. `lua/core/plugin_configs/gitsigns.lua` SHALL be removed or disabled from the runtime path and not required from `plugins.lua`.
3. mini.diff SHALL be configured via mini.nvim (already included) with a dedicated plugin config file consistent with project structure.
4. Headless load test `NVIM_APPNAME=neonvim nvim --headless -c 'quit'` SHALL succeed without errors or missing-require warnings.

### REQ-005: Performance and reliability

User Story: As a user, I want responsive hunk updates without UI jank, so that editing remains smooth.

Acceptance Criteria
1. The default debounce/delay (200ms) SHALL be used unless a specific regression is observed.
2. Hunk operations and navigation SHALL complete without noticeable lag on typical files (<10k LOC). If performance issues occur, document tuning options in design.

### REQ-006: Compatibility and failure modes

User Story: As a user, I want predictable behavior across environments, so that the setup works broadly without surprises.

Acceptance Criteria
1. Neovim compatibility: Works on the project’s baseline Neovim (>= 0.8 per mini.nvim, tested on current local version).
2. Git requirement: If git < 2.38 is detected, applying (staging) via mini.diff’s Git source MAY fail; such failures SHALL surface a clear error/notification without crashing.
3. Non-Git workspaces SHALL not enable Git-backed apply/reset and SHALL not crash.

### REQ-007: Statusline diff status integration (ACTIVE)

User Story: As a user, I want to see Git diff hunk summary (added/changed/deleted line counts) in my statusline, so that I have quick visibility of my working changes without leaving the buffer.

Acceptance Criteria
1. The statusline SHALL display diff hunk summary from `vim.b.minidiff_summary_string` when available (Git buffers with changes).
2. The diff summary SHALL appear in the LEFT section alongside existing git branch information (MiniStatuslineDevinfo highlight group).
3. The diff summary SHALL NOT appear for non-Git buffers or Git buffers with no changes (graceful empty string).
4. The display format SHALL be compact and consistent with mini.statusline's existing git section style.
5. Implementation SHALL follow the component-based structure documented in `lua/core/plugin_configs/statusline.lua` (CUSTOM COMPONENTS section).
6. The component SHALL handle truncation appropriately (use `ms.is_truncated(trunc_width)` with same threshold as git section: 75).
