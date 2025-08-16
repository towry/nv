# Native pack layout

This folder documents how to install plugins using Neovim's built-in "packages" (native `pack`) system.

Key points:

- Neovim searches for a `pack` directory inside paths listed in the `&packpath` option.
- Inside a `pack/<group>` directory create two folders: `start` and `opt`.
  - `start` plugins are loaded automatically on startup.
  - `opt` plugins are optional and must be loaded with `:packadd <plugin>`.
- The group name is arbitrary (for example `vendor`, `plugins`, or `github`).

Typical layout for this config (relative to this repo root):

```
pack/plugins/
  start/
    some-plugin/        (installed as a git clone of the plugin)
  opt/
    another-plugin/
```

Example: install a plugin so it loads automatically

```sh
# clone into start so it is loaded at startup
git clone https://github.com/nvim-lualine/lualine.nvim \
  "$HOME/.config/neonvim/pack/plugins/start/lualine.nvim"
```

Example: install a plugin but load it on demand

```sh
git clone https://github.com/echasnovski/mini.nvim \
  "$HOME/.config/neonvim/pack/plugins/opt/mini.nvim"
# then in Neovim: :packadd mini.nvim
```

Using a separate config instance via NVIM_APPNAME

Neovim's `NVIM_APPNAME` environment variable controls the config directory used by Neovim. To run Neovim with this config without touching your main `~/.config/nvim`, use:

```sh
NVIM_APPNAME=neonvim nvim
```

To test loading the config headless (useful for CI or quick syntax checks):

```sh
NVIM_APPNAME=neonvim nvim --headless -c 'quit'
```

Notes:

- You can inspect the runtime `packpath` from inside Neovim with `:set packpath?` or in Lua with `vim.opt.packpath:get()`.
- For lazy-loading behavior consider using `opt` + `:packadd` or a plugin manager that understands the native packages layout.
# Plugins for neonvim

Neonvim uses Neovim's native `pack` directory for plugin management.

- Place plugins you want always loaded in `pack/plugins/start/<plugin>`
- Place optional plugins in `pack/plugins/opt/<plugin>` and load with `:packadd <plugin>`

Example (git clone a plugin):

```sh
# always loaded
git clone https://github.com/preservim/nerdtree.git \
  ~/.config/neonvim/pack/plugins/start/nerdtree

# optional
git clone https://github.com/itchyny/lightline.vim.git \
  ~/.config/neonvim/pack/plugins/opt/lightline
```

Run Neovim with this config using:

```sh
NVIM_APPNAME=neonvim nvim
```

Use headless mode to test loading:

```sh
NVIM_APPNAME=neonvim nvim --headless -c 'quit'
```
