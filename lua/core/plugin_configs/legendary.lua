-- Legendary.nvim configuration
-- Keybind finder and management

local M = {}

pcall(function()
  local legendary = require('legendary')

  -- Set up legendary with fzf-lua UI provider
  legendary.setup({
    -- Keybinds will be automatically sourced from which-key.nvim
    -- and any other sources you configure
    select_prompt = ' legendary.nvim ',
    include_builtin = true,
    include_legendary_cmds = true,
    include_auto_groups = false,

    -- Use fzf-lua as the UI provider for better select experience
    -- This requires dressing.nvim or direct fzf-lua integration
    ui = {
      -- Configure fzf-lua as the select backend
      select = {
        -- Use fzf-lua for the select UI
        backend = 'fzf_lua',
        -- fzf-lua specific options
        fzf_lua = {
          -- Custom fzf-lua options for legendary.nvim
          winopts = {
            width = 0.8,
            height = 0.6,
            border = 'rounded',
          },
          -- Prompt customization
          prompt = ' legendary.nvim > ',
          -- Additional fzf options
          fzf_opts = {
            ['--layout'] = 'reverse',
            ['--info'] = 'inline',
            ['--pointer'] = '▶',
            ['--marker'] = '✓',
          },
        },
      },
    },

    -- Customize the icons
    icons = {
      keymap = ' ',
      command = ' ',
      fn = '󰡱 ',
      itemgroup = ' ',
    },

    -- Customize the sorting
    sort = {
      -- Sort by frequency (most used first)
      frequency = false,
      -- Sort by most recently used
      recent = false,
      -- Sort by priority (set via legendary.keymap/set/etc.)
      priority = true,
    },

    -- Default options for keymaps
    default_opts = {
      keymaps = {
        silent = true,
        noremap = true,
      },
    },
  })
end)

return M
