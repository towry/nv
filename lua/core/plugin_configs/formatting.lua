local M = {}

-- Initialize autoformat setting
if vim.g.autoformat == nil then
  vim.g.autoformat = true
end

-- Conform.nvim configuration
M.config = {
  default_format_opts = {
    lsp_format = "fallback",
    timeout_ms = 1500,
  },
  format_on_save = function(bufnr)
    -- Skip in diff mode
    if vim.wo[0].diff then
      return nil
    end
    
    -- Initialize global autoformat if nil
    if vim.g.autoformat == nil then
      vim.g.autoformat = true
    end
    
    -- Check buffer setting first, then global
    local autoformat = vim.b[bufnr].autoformat
    if autoformat == nil then
      autoformat = vim.g.autoformat
    end
    
    if autoformat then
      return { timeout_ms = 500, lsp_format = "fallback" }
    end
    
    return nil
  end,
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "biome", "prettierd", "prettier" },
    javascriptreact = { "biome", "prettierd", "prettier" },
    typescript = { "biome", "prettierd", "prettier" },
    typescriptreact = { "biome", "prettierd", "prettier" },
    html = { "prettierd", "prettier" },
    css = { "prettierd", "prettier" },
    json = { "prettierd", "prettier" },
    yaml = { "prettierd", "prettier" },
    markdown = { "prettierd", "prettier" },
    python = { "ruff_format", "ruff_fix" },
    go = { "goimports", "gofmt" },
    rust = { "rustfmt" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
    elixir = { "mix" },
    toml = { "taplo" },
    nix = { "nixfmt" },
  },
  formatters = {
    -- Configure stop_after_first for JS/TS formatters
    biome = { stop_after_first = true },
    prettierd = { stop_after_first = true },
    prettier = { stop_after_first = true },
  },
}

-- Format command with range support
M.setup_commands = function()
  vim.api.nvim_create_user_command("Format", function(args)
    local range = nil
    if args.count ~= -1 then
      local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
      range = {
        start = { args.line1, 0 },
        ["end"] = { args.line2, end_line:len() },
      }
    end
    
    local ok, conform = pcall(require, "conform")
    if not ok then
      vim.notify("conform.nvim not available", vim.log.levels.ERROR)
      return
    end
    
    conform.format({ async = true, range = range })
  end, {
    desc = "Format buffer or selection",
    range = true,
  })
end

-- Setup keymaps
M.setup_keymaps = function()
  -- Normal mode mappings
  vim.keymap.set("n", "<leader>lf", function()
    vim.cmd.Format()
  end, { desc = "Format buffer" })
  
  vim.keymap.set("n", "<leader>uf", function()
    if vim.b.autoformat == nil then
      if vim.g.autoformat == nil then
        vim.g.autoformat = true
      end
      vim.b.autoformat = vim.g.autoformat
    end
    vim.b.autoformat = not vim.b.autoformat
    
    local status = vim.b.autoformat and "on" or "off"
    vim.notify(string.format("Buffer autoformatting %s", status), vim.log.levels.INFO)
  end, { desc = "Toggle autoformatting (buffer)" })
  
  vim.keymap.set("n", "<leader>uF", function()
    if vim.g.autoformat == nil then
      vim.g.autoformat = true
    end
    vim.g.autoformat = not vim.g.autoformat
    vim.b.autoformat = nil
    
    local status = vim.g.autoformat and "on" or "off"
    vim.notify(string.format("Global autoformatting %s", status), vim.log.levels.INFO)
  end, { desc = "Toggle autoformatting (global)" })
  
  -- Visual mode mapping for selection formatting
  vim.keymap.set("v", "<leader>lf", function()
    vim.cmd.Format()
  end, { desc = "Format selection" })
end

-- Setup which-key integration
M.setup_whichkey = function()
  local wk_ok, which_key = pcall(require, "which-key")
  if not wk_ok then
    return
  end
  
  which_key.add({
    { "<leader>l", group = "LSP", icon = { icon = "λ", color = "purple" } },
    { "<leader>lf", desc = "Format buffer/selection" },
    { "<leader>u", group = "UI/Toggles", icon = { icon = "󱠇", color = "cyan" } },
    { "<leader>uf", desc = "Toggle autoformat (buffer)" },
    { "<leader>uF", desc = "Toggle autoformat (global)" },
  })
end

-- Main setup function
M.setup = function()
  local conform_ok, conform = pcall(require, "conform")
  if not conform_ok then
    return
  end
  
  -- Setup conform.nvim
  conform.setup(M.config)
  
  -- Setup commands and keymaps
  M.setup_commands()
  M.setup_keymaps()
  M.setup_whichkey()
end

-- Auto-run setup when module is loaded
M.setup()

return M