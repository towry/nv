-- Gitsigns configuration
local M = {}

-- Check if gitsigns is available
local has_gitsigns, gitsigns = pcall(require, 'gitsigns')
if not has_gitsigns then
  return M
end

-- Only enable in git repositories
local function is_git_repo()
  local cwd = vim.fn.expand('%:p:h')
  local result = vim.fn.system('git -C ' .. vim.fn.shellescape(cwd) .. ' rev-parse 2>/dev/null')
  return vim.v.shell_error == 0
end

-- Setup gitsigns if in git repo
if is_git_repo() then
  gitsigns.setup({
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    signcolumn = true,
    numhl = false,
    linehl = false,
    word_diff = false,
    watch_gitdir = {
      interval = 1000,
      follow_files = true,
    },
    attach_to_untracked = true,
    current_line_blame = false,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol',
      delay = 1000,
    },
    current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil,
    max_file_length = 40000,
    preview_config = {
      border = 'single',
      style = 'minimal',
      relative = 'cursor',
      row = 0,
      col = 1,
    },
    on_attach = function(bufnr)
      local gs = gitsigns

      -- Navigation (which-key will pick these up automatically via desc)
      vim.keymap.set('n', ']c', function()
        if vim.wo.diff then
          return ']c'
        end
        vim.schedule(function()
          gs.next_hunk()
        end)
        return '<Ignore>'
      end, { expr = true, buffer = bufnr, desc = 'Next git hunk' })

      vim.keymap.set('n', '[c', function()
        if vim.wo.diff then
          return '[c'
        end
        vim.schedule(function()
          gs.prev_hunk()
        end)
        return '<Ignore>'
      end, { expr = true, buffer = bufnr, desc = 'Previous git hunk' })

      -- Actions (which-key will pick these up automatically via desc)
      vim.keymap.set('n', '<leader>ghs', gs.stage_hunk, { buffer = bufnr, desc = 'Stage hunk' })
      vim.keymap.set('n', '<leader>ghr', gs.reset_hunk, { buffer = bufnr, desc = 'Reset hunk' })
      vim.keymap.set('n', '<leader>gB', gs.toggle_current_line_blame, { buffer = bufnr, desc = 'Toggle line blame' })

      -- Text object
      vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { buffer = bufnr })
    end,
  })
end

return M