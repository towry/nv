# Agent Guidelines

## Build/Test/Lint

- **Test config load**: `nvim --headless -c 'quit'`
- **Run with config**: `nvim`
- **Reinstall plugins**: `nvim --headless -c "lua require('core.plugins')" -c 'quit'`
- No formal linter; validate Lua syntax via headless load test above

## Code Style

- **Indentation**: 2 spaces, `expandtab = true`
- **Imports**: Wrap all `require()` calls in `pcall(require, 'module')` to avoid errors when plugins missing
- **Types**: Lua (no type annotations); use clear variable names and inline comments for complex logic
- **Naming**: snake_case for variables/functions, PascalCase for module tables (e.g., `local M = {}`)
- **Error handling**: Use `pcall` for plugin/module loads; `vim.notify(..., vim.log.levels.ERROR)` for user-facing errors
- **Keymaps**: Use multi-key sequences after leader (e.g., `<leader>ff`), avoid single-key mappings that block trees. Group related actions with common prefixes (e.g., `<leader>f*` for fzf-lua, `<leader>g*` for git)

## Project Structure

- **Entry point**: `init.lua` loads `lua/core/*` (options, keymaps, autocmds, plugins)
- **Plugin management**: `lua/core/plugins.lua` uses `vim.pack.add()` (native, not packer/lazy)
- **Per-plugin configs**: `lua/core/plugin_configs/*.lua` (one file per plugin, loaded via `pcall`)
- **Keymaps**: Global in `lua/core/keymaps.lua`, plugin-specific in plugin config files
- **Pack layout**: `pack/plugins/{start,opt}` ignored by git; manual install documented in `pack/plugins/README.md`
- **Documentation**: Technical reference docs go in `llm/steering/`, with brief pointers in this file

## Version Control (jj/Jujutsu)

- **Commit**: `jj ci -m "short message"`
- **Move main**: `jj mv main --to <new rev>`
- **Push**: `jj push main`

## Rules

- See @.github/copilot-instructions.md for detailed conventions (keymap strategy, research-first workflow, safe changes)
- When user ask how to about plugin usage, use the research-first workflow to provide accurate and helpful responses, collect documentation from external resources
- **Legendary.nvim**: See llm/steering/legendary-setup.md for registration patterns and API usage
