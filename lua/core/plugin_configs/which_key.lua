-- Which-key configuration for neonvim
-- Provides key binding hints and leader groups

local M = {}

-- Check if which-key is available
local wk_ok, wk = pcall(require, 'which-key')
if not wk_ok then
  vim.notify('Which-key not available', vim.log.levels.WARN)
  return M
end

-- Configure which-key with settings from old config
wk.setup({
  notify = true,
  triggers = {
    { "<auto>", mode = "nixsotc" },
  },
  delay = function(ctx) 
    return ctx.plugin and 0 or 150 
  end,
  defer = function(ctx) 
    return ctx.mode == "V" or ctx.mode == "<C-V>" 
  end,
  preset = "helix",
  win = {
    no_overlap = true,
    border = "single",
    title_pos = "center",
    wo = {
      winblend = 20,
    },
  },
  -- Only show mappings with descriptions
  filter = function(m) return m.desc and m.desc ~= "" end,
  -- Expand groups with <= 1 child to avoid "+1 keymaps"
  expand = 1,
})

-- Centralized group labels only
wk.add({
  { "<leader>b", group = "Buffers" },
  { "<leader>n", group = "New" },
  { "<leader>f", group = "Find" },
  { "<leader>j", group = "Jump" },
  { "<leader>g", group = "Git" },
  { "<leader>gh", group = "Hunk" },
  { "<leader>l", group = "LSP" },
  { "<leader>t", group = "Tasks" },
  { "<leader>u", group = "Toggle/UI" },
  { "<C-w>", group = "Windows" },
  { "<C-c>", group = "Control" },
  { "<localleader>", group = "Local Leader" },
}, { mode = "n" })

-- Defer Copilot mappings until after plugins load
vim.defer_fn(function()
  -- Copilot mappings for which-key
  wk.add({
    { "<leader>ua", function() 
      if vim.g.copilot_auto_mode == true then
        vim.g.copilot_auto_mode = false
        vim.g.copilot_filetypes = vim.tbl_extend("keep", { ["*"] = false }, vim.g.copilot_filetypes)
        vim.cmd("Copilot disable")
        vim.notify("Copilot auto mode disabled ✕")
      else
        vim.g.copilot_auto_mode = true
        vim.g.copilot_filetypes = vim.tbl_extend("keep", { ["*"] = true }, vim.g.copilot_filetypes)
        vim.cmd("Copilot enable")
        vim.fn["copilot#OnFileType"]()
        vim.notify("Copilot auto mode enabled ✔")
      end
    end, desc = "Toggle Copilot auto" },
    { "<leader>u<cr>", function() 
      if vim.g.copilot_enabled == 1 then
        vim.cmd('Copilot disable')
        vim.notify('🤖 Copilot disabled', vim.log.levels.INFO, { key = 'copilot' })
      else
        vim.cmd('Copilot enable')
        vim.notify('🤖 Copilot enabled', vim.log.levels.INFO, { key = 'copilot' })
      end
    end, desc = "Toggle Copilot" },
  }, { mode = "n" })

  -- Which-key labels for Overseer are picked up via desc on keymaps in normal mode under <leader>t group


  -- Insert mode Copilot mappings
  wk.add({
    { "<M-j>", desc = "Copilot next suggestion" },
    { "<M-k>", desc = "Copilot previous suggestion" },
    { "<C-g>", desc = "Complete with Copilot" },
  }, { mode = "i" })
end, 200)

-- Helper functions for complex mappings
local function smart_close_window()
  local tabs_count = vim.fn.tabpagenr("$")
  if tabs_count <= 1 then
    vim.cmd('hide')
    vim.cmd('echo "hide current window"')
    return
  end
  local win_count = vim.fn.winnr('$')
  if win_count <= 1 then
    local choice = vim.fn.confirm("Close last window in tab?", "&Yes\n&No", 2)
    if choice == 2 then return end
  end
  vim.cmd('hide')
  vim.cmd('echo "hide current window"')
end

local function drop_float_to_new_tab()
  local current_buf = vim.api.nvim_get_current_buf()
  vim.cmd("tabnew")
  vim.cmd("b" .. current_buf)
end

local function smart_delete_buffer()
  if vim.fn.exists("&winfixbuf") == 1 and vim.api.nvim_get_option_value("winfixbuf", { win = 0 }) then
    vim.cmd("hide")
    return
  end
  vim.cmd("bdelete")
end

local function paste_next_line_format()
  local reg = vim.v.register or '"'
  vim.cmd(":put " .. reg)
  vim.cmd([[normal! `[v`]=]])
end

local function paste_above_line_format()
  local reg = vim.v.register or '"'
  vim.cmd(":put! " .. reg)
  vim.cmd([[normal! `[v`]=]])
end

-- Register only complex mappings that can't be auto-discovered
local function register_complex_mappings()
  -- Window management
  vim.keymap.set("n", "<c-w><space>", function() wk.show({ keys = "<c-w>", loop = true }) end, { 
    desc = "Window Hydra mode (which-key)" 
  })

  -- Jump: Flash replacement via mini.jump2d
  vim.keymap.set("n", "<leader><leader>", function()
    require('mini.jump2d').start()
  end, { desc = "Jump: labelled (mini.jump2d)" })

  -- Tasks: Overseer basic controls
  vim.keymap.set("n", "<leader>tt", ":OverseerRun<cr>", { desc = "Tasks: Run" })
  vim.keymap.set("n", "<leader>tr", ":OverseerRunCmd<cr>", { desc = "Tasks: Run command" })
  vim.keymap.set("n", "<leader>tl", ":OverseerToggle<cr>", { desc = "Tasks: List/Toggle" })
  vim.keymap.set("n", "<leader>ta", ":OverseerQuickAction<cr>", { desc = "Tasks: Quick action" })
  vim.keymap.set("n", "<leader>tq", ":OverseerQuickAction open quickfix<cr>", { desc = "Tasks: Open quickfix for last task" })

  -- Quick mappings
  vim.keymap.set("n", "Q", "<cmd>qall<cr>", { desc = "Quit all" })
  vim.keymap.set("n", ";", ":", { desc = "Command mode" })

  -- Visual mode mappings
  vim.keymap.set("v", "dp", "<cmd>'<,'>diffput<cr>", { desc = "Diffput in visual" })
  vim.keymap.set("v", "do", "<cmd>'<,'>diffget<cr>", { desc = "Diffget in visual" })
  vim.keymap.set("v", "J", ":move '>+1<CR>gv-gv", { desc = "Move selected text down" })
  vim.keymap.set("v", "K", ":move '<-2<CR>gv-gv", { desc = "Move selected text up" })

  -- Navigation mappings (simplified buffer navigation)
  vim.keymap.set("n", "<C-n>", "<cmd>bnext<cr>", { desc = "Next buffer" })
  vim.keymap.set("n", "<C-p>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
  vim.keymap.set("n", "';", "<cmd>b#<cr>", { desc = "Previous buffer" })

  -- Window control mappings
  vim.keymap.set("n", "<C-c><C-k>", smart_close_window, { desc = "Kill current window" })
  vim.keymap.set("n", "<C-c><C-f>", drop_float_to_new_tab, { desc = "Drop float win to new tab" })
  vim.keymap.set("n", "<C-c><C-d>", smart_delete_buffer, { desc = "Delete current buffer" })

  vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window focus left" })
  vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window focus down" })
  vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window focus up" })
  vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window focus right" })

  vim.keymap.set("n", "<A-h>", "<C-w><", { desc = "Resize split left" })
  vim.keymap.set("n", "<A-j>", "<C-w>-", { desc = "Resize split down" })
  vim.keymap.set("n", "<A-k>", "<C-w>+", { desc = "Resize split up" })
  vim.keymap.set("n", "<A-l>", "<C-w>>", { desc = "Resize split right" })

  -- Quickfix toggle
  vim.keymap.set("n", "<A-q>", function() 
    if vim.bo.filetype == "qf" then
      vim.cmd("wincmd p")
    else
      vim.cmd("copen")
    end
  end, { desc = "Switch quickfix window" })

  -- NOTE: Overseer keymaps defined above rely on overseer.nvim being present;
  -- they are safe even if plugin is not yet loaded (commands are defined by plugin).

  -- Fold navigation
  vim.keymap.set("n", "H", function() 
    local has_folded = vim.fn.foldclosed(".") > -1
    local is_at_first_non_whitespace_char_of_line = (vim.fn.col(".") - 1) == vim.fn.match(vim.fn.getline("."), "\\S")
    if is_at_first_non_whitespace_char_of_line and not has_folded then 
      return "za" 
    end
    if vim.fn.foldclosed(".") == -1 then 
      return "^" 
    end
  end, { desc = "First char / fold line", expr = true })

  vim.keymap.set("n", "L", function() 
    if vim.fn.foldclosed(".") > -1 then
      return "zo"
    else
      return "$"
    end
  end, { desc = "Last char / unfold line", expr = true })

  -- Select pasted text
  vim.keymap.set("n", "g<C-v>", "`[v`]", { desc = "Select pasted text" })

  -- Git mappings (if in git context)
  if vim.fn.exists(':Git') == 2 then
    vim.keymap.set("n", "<localleader>w", ":w|cq 0<cr>", { desc = "Git mergetool: prepare write and exit safe" })
    vim.keymap.set("n", "<localleader>c", ":cq 1<cr>", { desc = "Git mergetool: Prepare to abort" })
  end

  -- LSP mappings (when LSP is attached)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local bufnr = args.buf
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Declaration of current symbol", buffer = bufnr })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover symbol details", buffer = bufnr })
      -- NOTE: <C-k> in insert mode is intentionally unbound for LSP to avoid conflict with mini.snippets
      -- mini.snippets uses <C-k> for jumping backward in snippets
    end,
  })
end

-- Register complex mappings after plugins are loaded
vim.defer_fn(register_complex_mappings, 100) -- NOTE: defer ensures which-key UI is ready

return M