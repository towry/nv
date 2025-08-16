# GitHub Copilot instructions for neonvim repo

Purpose: give an AI coding agent the essential, actionable knowledge to make safe, small, high-value changes in this minimal Neovim config.

Quick facts

- Entry point: `init.lua` (loads `lua/core/*`). Keep changes minimal and non-breaking.
- Plugin management: `lua/core/plugins.lua` uses built-in `vim.pack.add()` (not third-party managers). Avoid replacing with packer/lazy unless requested.
- Per-plugin configs live in `lua/core/plugin_configs/` (one file per plugin). Prefer adding or editing those instead of cramming logic into `plugins.lua`.
- Pack layout: repo uses native `pack` under `pack/plugins`. `pack/plugins/README.md` documents manual install; `.gitignore` ignores `pack/plugins/start/*` and `.../opt/*` by default.

What an agent can safely do

1. Add a new plugin:
   - Add its `src` (Git URL) to the `plugins` table in `lua/core/plugins.lua`.
   - Create `lua/core/plugin_configs/<plugin>.lua` that `pcall(require, '<module>')` and configure the plugin safely.
   - Add any keymaps to `lua/core/keymaps.lua` or export them from the plugin config module, group plugins keymaps together at bottom, put common keymaps at the top.
   - Validate by running headless: `NVIM_APPNAME=neonvim nvim --headless -c 'quit'`.

Research-first workflow

- Before adding a new feature or plugin, use GitHub search_code tool to find example configs/usages (e.g., plugin READMEs, minimal Neovim setups). Adapt only the minimal patterns needed into `lua/core/plugin_configs/<plugin>.lua`, wire it via `lua/core/plugins.lua`, then validate headless.

2. Change editor options, keymaps, or autocmds:
   - Edit `lua/core/options.lua`, `lua/core/keymaps.lua`, `lua/core/autocmds.lua` respectively.
   - Keep changes small and test with headless Neovim.

3. Documentation and housekeeping edits:
   - Update `pack/plugins/README.md`, `PROJECT.md`, `README.md`, or `.gitignore` as needed.

Project-specific conventions

- Single responsibility config modules: plugin setup must be isolated in `lua/core/plugin_configs/*` and should not error if the plugin isn't installed (wrap with `pcall(require, '...')`).
- Use `vim.pack.add()` with `{ confirm = false }` in headless contexts. Do not assume interactive prompts.
- Keymaps: global/basic ones live in `lua/core/keymaps.lua`. Plugin-specific keymaps belong in the plugin's config file.
- Keymap strategy:
   - Avoid single-key mappings after leader (e.g., `<leader>w`) as they block entire key trees
   - Use descriptive multi-key sequences that follow logical namespaces (e.g., `<leader>ft` for file-tree)
   - Group related actions with common prefixes (e.g., `<leader>g?` for git operations)
   - Document keymap categories in comments within keymaps.lua
   - Create keys only for frequently used actions
   - Use legendary.nvim for other actions
- Avoid committing third-party plugin checkouts: `.gitignore` excludes `pack/plugins/start/*` and `pack/plugins/opt/*`.

Build/test/debug workflow

- Fast syntax/load smoke test:

```
NVIM_APPNAME=neonvim nvim --headless -c 'quit'
```

- Re-run plugin installation (headless):

```
NVIM_APPNAME=neonvim nvim --headless -c "lua require('core.plugins')" -c 'quit'
```

- Inspect runtime packpath inside Neovim:

```
NVIM_APPNAME=neonvim nvim --headless -c "lua print(vim.inspect(vim.opt.packpath:get()))" -c 'quit'
```

Files & locations to reference

- `init.lua` — main loader
- `lua/core/options.lua` — editor options
- `lua/core/keymaps.lua` — keymaps
- `lua/core/autocmds.lua` — autocommands
- `lua/core/plugins.lua` — plugin declarations using `vim.pack`
- `lua/core/plugin_configs/*.lua` — per-plugin configuration
- `pack/plugins/README.md` — native pack usage notes
- `PROJECT.md` — project goals & roadmap

Do NOT do these changes without explicit instruction

- Replace `vim.pack` with a different plugin manager without user's approval.
- Check in `pack/plugins/start/*` plugin repositories (they are git clones and ignored by default).
- Make global keymap changes without updating `keymaps.lua` and documenting them.

If something is unclear

- If a requested change touches plugin install strategy or tracking (committing vendor plugins), ask whether to keep plugins out of source control or vendor them in. Also ask whether to adopt a plugin manager.
- If a requested plugin requires native dependencies (rg, ctags, etc.), ask whether the user wants checks or install instructions added to `PROJECT.md`.

When user satisfy current changes, commit the changes and push to remote.
