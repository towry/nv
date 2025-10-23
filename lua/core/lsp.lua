-- Core LSP settings for neonvim (editor behavior only)
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
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'References', buffer = bufnr })
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Implementations', buffer = bufnr })
    vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, { desc = 'LSP rename', buffer = bufnr })
    vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, { desc = 'Code action', buffer = bufnr })
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Prev diagnostic', buffer = bufnr })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic', buffer = bufnr })
    vim.keymap.set('n', '<leader>ld', function()
      vim.diagnostic.open_float(nil, { focusable = false })
    end, { desc = 'Line diagnostics', buffer = bufnr })
  end,
})

-- Native LSP defaults and enablement using Neovim 0.12+ API
do
  local ok_config = type(vim.lsp.config) == 'function'
  local ok_enable = type(vim.lsp.enable) == 'function'
  if not (ok_config and ok_enable) then
    -- NOTE: Silent skip per user request (no warnings). Native LSP setup requires newer Neovim.
    return
  else
    -- Apply shared defaults; keep minimal and let per-server configs augment
    vim.lsp.config('*', {})

    -- Default server set (without TS; handle TS with preference below)
    local default_servers = {
      'lua_ls', 'html', 'cssls', 'pyright', 'elixirls', 'bashls', 'marksman', 'jsonls', 'yamlls', 'taplo',
    }

    local servers = vim.g.lsp_enabled_servers or default_servers

    -- Determine TypeScript server preference: ts_ls first, fallback to tsserver if available
    local ts_choice
    do
      local ok_tsls, _ = pcall(require, 'lsp.ts_ls')
      if ok_tsls then
        ts_choice = 'ts_ls'
      else
        local ok_tss, _ = pcall(require, 'lsp.tsserver')
        if ok_tss then ts_choice = 'tsserver' end
      end
    end
    if ts_choice then table.insert(servers, ts_choice) end

    -- Load per-server configs if present and enable only those with configs
    local to_enable = {}
    for _, name in ipairs(servers) do
      local ok_mod, conf = pcall(require, 'lsp.' .. name)
      if ok_mod and type(conf) == 'table' then
        vim.lsp.config(name, conf)
        table.insert(to_enable, name)
      else
        vim.schedule(function()
          vim.notify('No config for LSP server "' .. name .. '". Create lua/lsp/' .. name .. '.lua or install via mason.', vim.log.levels.WARN)
        end)
      end
    end

    if #to_enable > 0 then
      vim.lsp.enable(to_enable)
    else
      vim.schedule(function()
        vim.notify('No LSP servers enabled (missing configs). See lua/lsp/*.lua.', vim.log.levels.INFO)
      end)
    end
  end
end

return M