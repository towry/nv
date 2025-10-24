-- fzf-lua configuration
return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  config = function()
    local config = require("fzf-lua.config")
    local local_actions = require("core.plugin_configs.fzf_actions")
    
    -- Keymap configurations
    config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
    config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
    config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
    config.defaults.keymap.fzf["ctrl-x"] = "jump"
    config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
    config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
    config.defaults.keymap.fzf["tab"] = "toggle+down"
    config.defaults.keymap.fzf["shift-tab"] = "toggle+up"
    config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
    config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"
    config.defaults.actions.files["ctrl-o"] = local_actions.files_open_in_window
    
    require("fzf-lua").setup({
      "defaults",
      defaults = {
        formatter = "path.filename_first",
        file_icons = true,
      },
      winopts = {
        height = 0.95,
        width = 0.85,
        backdrop = 100,
        border = "single",
        preview = {
          delay = 50,
          layout = "flex",
          flip_columns = 240,
          horizontal = "right:45%",
          vertical = "down:40%",
          border = "single",
        },
        treesitter = false,
      },
      fzf_colors = false,
      fzf_opts = {
        ["--ansi"] = false,
        ["--info"] = "inline-right",
        ["--height"] = "100%",
        ["--cycle"] = true,
        ["--no-separator"] = "",
      },
     files = {
       git_icons = false,
       file_icons = false,
     },
      grep = {
        rg_glob = true,
        rg_glob_fn = function(query, opts)
          local regex, flags = query:match("^(.-)%s%-%-(.*)$")
          return (regex or query), flags
        end,
      },
      lsp = {
        jump1 = true,
        cwd_only = true,
        code_actions = {
          previewer = vim.fn.executable("delta") == 1 and "codeaction_native" or nil,
        },
        symbols = {
          symbol_style = 2,
        },
      },
    })
    require("fzf-lua").register_ui_select()
  end,
}
