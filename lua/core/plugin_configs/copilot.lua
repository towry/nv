-- Configuration for copilot.vim
pcall(function() vim.cmd('packadd copilot.vim') end)
vim.g.copilot_auto_mode = true
vim.g.copilot_workspace_folders = { vim.fn.getcwd() }
vim.g.copilot_filetypes = {
  ["*"] = true,
  ["fzf"] = false,
  ["OverseerForm"] = false,
}
vim.g.copilot_no_tab_map = true
vim.g.copilot_tab_fallback = ""
vim.g.copilot_assume_mapped = true

-- Enable suggestion text clearing when using completion menu
local function setup_copilot_integration()
  -- Close copilot panel with 'q'
  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "copilot.*",
    callback = function(ctx)
      vim.keymap.set("n", "q", "<cmd>close<cr>", {
        silent = true,
        buffer = ctx.buf,
        noremap = true,
      })
    end,
  })

  -- Toggle copilot auto-mode command
  vim.api.nvim_create_user_command("ToggleCopilotAutoMode", function()
    if vim.g.copilot_auto_mode == true then
      vim.g.copilot_auto_mode = false
      vim.g.copilot_filetypes = vim.tbl_extend("keep", {
        ["*"] = false,
      }, vim.g.copilot_filetypes)
      vim.cmd("Copilot disable")
      vim.notify("Copilot auto mode disabled ✕")
    else
      vim.g.copilot_auto_mode = true
      vim.g.copilot_filetypes = vim.tbl_extend("keep", {
        ["*"] = true,
      }, vim.g.copilot_filetypes)
      vim.cmd("Copilot enable")
      vim.fn["copilot#OnFileType"]()
      vim.notify("Copilot auto mode enabled ✔")
    end
  end, {})
end

setup_copilot_integration()

-- Keymaps for Copilot (in insert mode)
-- These will be registered via which-key config
vim.keymap.set('i', '<M-j>', function()
  if vim.fn.exists('*copilot#GetDisplayedSuggestion') == 1 then
    local suggestion = vim.fn['copilot#GetDisplayedSuggestion']()
    if suggestion.text ~= "" then
      vim.fn['copilot#Next']()
    end
  end
end, { noremap = true, silent = true })

vim.keymap.set('i', '<M-k>', function()
  if vim.fn.exists('*copilot#GetDisplayedSuggestion') == 1 then
    local suggestion = vim.fn['copilot#GetDisplayedSuggestion']()
    if suggestion.text ~= "" then
      vim.fn['copilot#Previous']()
    end
  end
end, { noremap = true, silent = true })

vim.keymap.set('i', '<C-g>', function()
  -- Close completion menu if visible
  local has_blink, blink = pcall(require, 'blink.cmp')
  if has_blink and blink.is_menu_visible() then
    blink.hide()
  end

  -- Trigger copilot suggestion or accept if available
  if vim.fn.exists('*copilot#GetDisplayedSuggestion') == 1 then
    local suggestion = vim.fn['copilot#GetDisplayedSuggestion']()
    if suggestion.text ~= "" then
      vim.fn.feedkeys(vim.fn['copilot#Accept'](), 'i')
    else
      vim.notify('🤖 Copilot is thinking..', vim.log.levels.INFO, { key = 'copilot' })
      vim.fn['copilot#Suggest']()
    end
  end
end, { noremap = true, silent = true, expr = false })

-- Normal mode keymaps for toggle
vim.keymap.set('n', '<leader>ua', function()
  vim.cmd('ToggleCopilotAutoMode')
end, { noremap = true, silent = true })

vim.keymap.set('n', '<leader>u<cr>', function()
  if vim.g.copilot_enabled == 1 then
    vim.cmd('Copilot disable')
    vim.notify('🤖 Copilot disabled', vim.log.levels.INFO, { key = 'copilot' })
  else
    vim.cmd('Copilot enable')
    vim.notify('🤖 Copilot enabled', vim.log.levels.INFO, { key = 'copilot' })
  end
end, { noremap = true, silent = true })
