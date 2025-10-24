# Neovim Configuration

Lightweight Neovim setup using native `vim.pack.add()` API with a lockfile. No external plugin managers.

## Installation

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup

# Clone and launch
git clone <YOUR_REPO_URL> ~/.config/nvim
nvim
```

Verify: `nvim --headless -c 'quit'`

## Structure

```
~/.config/nvim/
├── init.lua
├── nvim-pack-lock.json
└── lua/core/
    ├── plugins.lua
    ├── plugin_configs/
    ├── options.lua
    ├── keymaps.lua
    └── autocmds.lua
```

## Plugin Management

**Add:** Edit `lua/core/plugins.lua`:
```lua
local plugins = {
  'https://github.com/user/plugin-name',
  { src = 'https://github.com/user/plugin-name', version = 'main' },
}
```

**Update:** `nvim --headless -c "lua require('core.plugins')" -c 'quit'`

**Remove:** Delete from `lua/core/plugins.lua` and `pack/plugins/start/`

Docs: `:help vim.pack`

## Customization

- **Settings:** Edit `lua/core/options.lua`
- **Keybindings:** Edit `lua/core/keymaps.lua`
- **Plugin config:** Add files to `lua/core/plugin_configs/`

## Troubleshooting

**Errors on startup:** `nvim --headless -c 'quit'` and check `:messages`

**Plugin issues:** Verify in `lua/core/plugins.lua`, reinstall plugins

**Performance:** `nvim --startuptime startup.log`
