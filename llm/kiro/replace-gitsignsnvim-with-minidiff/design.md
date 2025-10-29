# replace gitsigns.nvim with mini.diff Design Document

This design implements the approved Requirements to migrate from lewis6991/gitsigns.nvim to echasnovski/mini.diff while preserving key workflows and minimizing muscle-memory disruption.

References (authoritative docs/APIs)
- mini.diff docs: https://nvim-mini.org/mini.nvim/doc/mini-diff.html
- Neovim diff API (for context): https://neovim.io/doc/user/diff.html

## Overview

Replace gitsigns.nvim with mini.diff for per-line hunk visualization and hunk operations (apply/reset, navigation, textobject), with a thin compatibility layer for prior keymaps and reliance on fugitive for blame.

Prerequisites
- Neovim >= 0.8 (mini.nvim baseline)
- Git >= 2.38 for staging via mini.diff Git source (REQ-006)
- Existing plugins present: mini.nvim, vim-fugitive

Key Objectives
- Remove gitsigns.nvim and its config (REQ-004)
- Enable mini.diff with sane defaults and compatible keymaps (REQ-001, REQ-002)
- Use fugitive for blame (REQ-003)
- Maintain performance and reliability (REQ-005)

Non-goals and Scope Limitations
- Unstaging hunks (not supported by mini.diff)
- Recreating every gitsigns feature (focus only on accepted requirements)

## Architecture

System Design (high-level)

  plugins.lua ─┬─ remove gitsigns.nvim entry and its require()
               └─ ensure mini.nvim (already present)
  plugin_configs/
    gitsigns.lua (remove/disable)
    mini_diff.lua (new): setup mini.diff + keymaps
  fugitive.lua (unchanged blame map)
  statusline.lua (optionally read vim.b.minidiff_summary_string)

Data Flow
1. Buffer opens in Git repo → mini.diff attaches default Git source and computes hunks.
2. Hunks update on text changes (debounced 200ms) → visualization via signs or numbers.
3. User actions (apply/reset, navigation, textobject) invoke mini.diff APIs.
4. Buffer-local summary variables update for statusline usage.

## Components and Interfaces

Component: mini_diff configuration
- Setup API: require('mini.diff').setup({ view, source, delay, mappings, options })
  - Defaults acceptable; we will explicitly set view.style when needed and keep delay.text_change = 200.
- Buffer-local variables for statusline:
  - vim.b.minidiff_summary, vim.b.minidiff_summary_string
- Navigation API: MiniDiff.goto_hunk(direction, opts)
- Region ops API: MiniDiff.do_hunks(buf, action, opts)
- Operator: MiniDiff.operator(mode)
- Textobject: MiniDiff.textobject()
- Overlay: MiniDiff.toggle_overlay(buf)

Component: Keymap compatibility layer
- Goal: preserve ]c / [c, <leader>ghs / <leader>ghr, and ih while also keeping mini.diff defaults available.
- Strategy:
  - Navigation
    - Map ]c → MiniDiff.goto_hunk('next') with expr function that respects vim.wo.diff (return ']c' in diff mode, mimic gitsigns behavior).
    - Map [c → MiniDiff.goto_hunk('prev') similarly.
    - Keep mini.diff defaults of ]h / [h / [H / ]H active.
  - Actions
    - Map <leader>ghs (stage/apply) to operate on current hunk or current line using MiniDiff.do_hunks(0, 'apply', region around cursor). For Visual/operator usage, rely on mini.diff apply mapping 'gh'.
    - Map <leader>ghr (reset) similarly using MiniDiff.do_hunks(0, 'reset', ...). For Visual/operator usage, rely on 'gH'.
  - Textobject
    - Map omap/xmap 'ih' to MiniDiff.textobject() for consistency with prior 'Gitsigns select_hunk'. Keep default textobject mapping 'gh'.
  - Overlay
    - Map <leader>gO to MiniDiff.toggle_overlay(0).

Component: Blame behavior continuity
- Keep existing: fugitive mapping <leader>gb to :Git blame
- Remove gitsigns-only <leader>gB mapping; do not reintroduce a broken mapping

## Configuration (proposed)

MiniDiff setup example (exact code to be implemented later in plugin config):
- require('mini.diff').setup({
  - view = {
    - style = vim.go.number and 'number' or 'sign',
    - signs = { add = '+', change = '~', delete = '-' },  // optional for sign style
    - priority = 199,
  },
  - source = nil, // use default Git source
  - delay = { text_change = 200 },
  - mappings = {
    - apply = 'gh',  // keep defaults
    - reset = 'gH',
    - textobject = 'gh',
    - goto_first = '[H', goto_prev = '[h', goto_next = ']h', goto_last = ']H',
  },
  - options = { algorithm = 'histogram', indent_heuristic = true, linematch = 60, wrap_goto = false },
})

Keymaps (buffer-local on attach)
- Navigation compatibility:
  - ]c → function()
    - if vim.wo.diff then return ']c' end
    - MiniDiff.goto_hunk('next'); return '<Ignore>'
  - [c → function()
    - if vim.wo.diff then return '[c' end
    - MiniDiff.goto_hunk('prev'); return '<Ignore>'
- Actions:
  - <leader>ghs → function() MiniDiff.do_hunks(0, 'apply', { line_start = vim.fn.line('.'), line_end = vim.fn.line('.') }) end
  - <leader>ghr → function() MiniDiff.do_hunks(0, 'reset', { line_start = vim.fn.line('.'), line_end = vim.fn.line('.') }) end
  - Note: Visual and operator flows use built-in 'gh'/'gH' mappings.
- Textobject:
  - omap ih → MiniDiff.textobject()
  - xmap ih → MiniDiff.textobject()
- Overlay:
  - <leader>gO → MiniDiff.toggle_overlay(0)

Statusline integration (ACTIVE)
- mini.diff updates vim.b.minidiff_summary_string once attached (format: "+2 ~1 -3" or similar).
- Add a custom component `section_diff_summary(trunc_width)` in statusline.lua CUSTOM COMPONENTS section.
- Component implementation:
  - Check truncation with `ms.is_truncated(trunc_width)` using threshold 75 (same as git section).
  - Read `vim.b.minidiff_summary_string` (returns nil for non-Git buffers or buffers with no changes).
  - Return empty string if nil/empty; otherwise return the summary string as-is (mini.diff formats it).
- Integration point: Add diff_summary to LEFT section in `build_active_statusline()`, combined with existing git section in MiniStatuslineDevinfo highlight group.
- Expected display: `[main +2 ~1 -3]` where `main` is branch and `+2 ~1 -3` is diff summary.
- No changes needed to mini.diff config (summary string is provided by default).

## Error Handling and Failure Modes
- Non-git buffers: Default source attach will fail; mini.diff remains disabled without errors (REQ-001.4, REQ-006.3).
- Git < 2.38: Applying hunks may error; surface via vim.notify on exception paths where we wire custom mappings (REQ-006.2). mini.diff itself will throw; do not swallow errors silently.
- Large files: If performance issues appear, consider tuning options.linematch or view style; document findings.

## Testing Strategy
Manual verification (headless load + interactive):
1. Headless load: NVIM_APPNAME=neonvim nvim --headless -c 'quit' → no errors (REQ-004.4)
2. Open a Git-tracked file with modifications:
   - Hunks appear (line numbers colored or signs depending on 'number').
   - Navigation works: ]c/[c and ]h/[h.
   - Actions work: <leader>ghs applies hunk; <leader>ghr resets.
   - Textobject ih selects hunk in operator/visual modes; 'gh' textobject also works.
   - Overlay toggles via <leader>gO.
3. Open a non-git file: no errors; mappings do not crash.
4. Blame: <leader>gb triggers :Git blame; no <leader>gB mapping remains.

## Migration and Rollout
Backwards Compatibility
- Keymap parity preserved for navigation and main actions; blame uses existing fugitive map.
- Some gitsigns features (e.g., unstaging) intentionally not replicated.

Deployment
1. Remove gitsigns plugin entry and require from plugins.lua; delete or disable plugin_configs/gitsigns.lua.
2. Add plugin_configs/mini_diff.lua with setup and mappings described.
3. Run headless load test and interactively verify as above.

Risks
- User muscle memory around gitsigns-only features not ported.
- Potential corner-cases around current-line vs whole-hunk operations via do_hunks.

Open Questions
- Closed: Use mini.diff default view style; no override irrespective of 'number'.
- Out of scope: quickfix export binding (MiniDiff.export('qf')) remains out of scope unless requested.
