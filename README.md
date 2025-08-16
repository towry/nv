
# neovim config

This is neovim config, use neovim's new pack for dep manage.

/Users/towry/workspace/nvim-doc contains all neovim docs.

read /Users/towry/workspace/nvim-doc/pack.txt about neovim's package system.

make sure the config is lightweight, use plugins only necessary.

run `NVIM_APPNAME=neonvim nvim` can run nvim with this config.

use headless mode to test neovim.

## Using this config

- Start Neovim with this config: `NVIM_APPNAME=neonvim nvim`
- Install plugins using the native pack layout under `pack/plugins/start` or `pack/plugins/opt` (see `pack/plugins/README.md`).

To test load in headless mode:

```
NVIM_APPNAME=neonvim nvim --headless -c 'quit'
```
