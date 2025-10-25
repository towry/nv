-- Core LSP settings (editor behavior only)
local M = {}

vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = { border = 'single' },
})

local function toggle_virtual_text()
  local current_config = vim.diagnostic.config()
  local new_virtual_text = not current_config.virtual_text
  vim.diagnostic.config({ virtual_text = new_virtual_text })
  vim.notify('Diagnostics virtual text: ' .. (new_virtual_text and 'enabled' or 'disabled'))
end

vim.keymap.set('n', '<leader>lV', toggle_virtual_text, { desc = 'Diagnostics: toggle virtual text' })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto definition', buffer = bufnr })
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Goto declaration', buffer = bufnr })
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Implementations', buffer = bufnr })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover', buffer = bufnr })
    vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, { desc = 'LSP rename', buffer = bufnr })
    vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, { desc = 'Code action', buffer = bufnr })
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev diagnostic', buffer = bufnr })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic', buffer = bufnr })
    vim.keymap.set('n', '<leader>ld', function()
      vim.diagnostic.open_float(nil, { focusable = false })
    end, { desc = 'Line diagnostics', buffer = bufnr })
  end,
})

-- Native LSP enablement using Neovim 0.12+ API
do
  local ok_enable = type(vim.lsp.enable) == 'function'
  if not ok_enable then
    -- NOTE: Silent skip per user request (no warnings). Native LSP enable() not available.
    return
  end

  -- If vim.lsp.config is unavailable or not a table, rely on "config-as-files" (lua/lsp/*.lua on runtimepath).
  local default_servers = {
    'lua_ls', 'html', 'cssls', 'pyright', 'elixirls', 'bashls', 'marksman', 'jsonls', 'yamlls', 'taplo',
  }
  local servers = vim.g.lsp_enabled_servers or default_servers

  -- Determine TypeScript server preference: ts_ls first, fallback to tsserver if available
  do
    local ok_tsls = pcall(require, 'lsp.ts_ls')
    if ok_tsls then
      table.insert(servers, 'ts_ls')
    else
      local ok_tss = pcall(require, 'lsp.tsserver')
      if ok_tss then table.insert(servers, 'tsserver') end
    end
  end

  -- Only enable servers that have a config-as-file present
  local to_enable = {}
  for _, name in ipairs(servers) do
    local ok_mod, conf = pcall(require, 'lsp.' .. name)
    if ok_mod and type(conf) == 'table' then
      if type(vim.lsp.config) == 'table' then
        -- Explicitly register the server configuration using table assignment (Neovim 0.12+)
        vim.lsp.config[name] = conf
      elseif type(vim.lsp.config) == 'function' then
        -- Fallback for older API (if function form exists)
        vim.lsp.config(name, conf)
      end
      table.insert(to_enable, name)
    else
      vim.schedule(function()
        vim.notify('LSP: missing config file for "' .. name .. '" (lua/lsp/' .. name .. '.lua). Skipping.', vim.log.levels.WARN)
      end)
    end
  end

  if #to_enable > 0 then
    for _, name in ipairs(to_enable) do
      -- Enable each server explicitly to avoid any ambiguity in list handling
      vim.lsp.enable(name)
    end
  else
    vim.schedule(function()
      vim.notify('LSP: no servers enabled (no config files found).', vim.log.levels.INFO)
    end)
  end
end

return M