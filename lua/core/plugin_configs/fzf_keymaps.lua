-- fzf-lua keymaps
local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Helper functions
local function V_nvim_root()
  return vim.fn.getcwd()
end

local function V_nvim_visual_text()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "" then
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local lines = vim.fn.getline(start_pos[2], end_pos[2])
    if #lines == 0 then return "" end
    
    if #lines == 1 then
      return string.sub(lines[1], start_pos[3], end_pos[3])
    else
      lines[1] = string.sub(lines[1], start_pos[3])
      lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
      return table.concat(lines, "\n")
    end
  end
  return ""
end

-- FzfLua keymaps
map("n", "<Leader>f.", "<cmd>FzfLua<cr>", { desc = "Open FzfLua" })
map("n", "<localleader>,", function()
  require("fzf-lua").oldfiles({ include_current_session = true })
end, { desc = "Recent files and buffers" })
map("n", "<leader>fb", "<cmd>FzfLua grep_curbuf<cr>", { desc = "Find in current buffer" })
map("n", "<Leader>fq", "<cmd>FzfLua quickfix<cr>", { desc = "Quickfix List" })
map("n", "<Leader>fj", "<cmd>FzfLua jumps<cr>", { desc = "Jumplist" })

-- Find files
map("n", "<Leader>ff", function()
  require("fzf-lua").files({
    cwd = V_nvim_root(),
  })
end, { desc = "Find files" })

-- Grep functionality
if vim.fn.executable("rg") == 1 or vim.fn.executable("grep") == 1 then
  map("n", "<Leader>fs", function()
    require("fzf-lua").grep({
      cwd = V_nvim_root(),
    })
  end, { desc = "Grep words" })
  
  map("n", "<Leader>fg", function()
    require("fzf-lua").live_grep({
      cwd = V_nvim_root(),
    })
  end, { desc = "Live grep" })
  
  map("v", "<Leader>fg", function()
    require("fzf-lua").live_grep({
      cwd = V_nvim_root(),
      query = V_nvim_visual_text(),
    })
  end, { desc = "Live grep (visual selection)" })
end

-- Find word under cursor
map("n", "<Leader>fc", function()
  require("fzf-lua").grep_cword({
    cwd = V_nvim_root(),
  })
end, { desc = "Find word under cursor" })

-- Other find commands
map("n", "<Leader>f;", function() require("fzf-lua").command_history() end, { desc = "Find commands history" })
map("n", "<Leader>f:", function() require("fzf-lua").commands() end, { desc = "Find commands" })
map("n", "<Leader>fh", function() require("fzf-lua").helptags() end, { desc = "Find help" })
map("n", "<Leader>fk", function() require("fzf-lua").keymaps() end, { desc = "Find keymaps" })
map("n", "<Leader>fm", function() require("fzf-lua").manpages() end, { desc = "Find man" })
map("n", "<Leader>fr", function() require("fzf-lua").registers() end, { desc = "Find registers" })
map("n", "<Leader>f<CR>", function() require("fzf-lua").resume() end, { desc = "Resume previous search" })
map("n", "<Leader>f'", function() require("fzf-lua").marks() end, { desc = "Find marks" })
map("n", "<Leader>f/", function() require("fzf-lua").lgrep_curbuf() end, { desc = "Find words in current buffer" })

-- Find config files
map("n", "<Leader>fXa", function()
  require("fzf-lua").files({ prompt = "Config> ", cwd = vim.fn.stdpath("config") })
end, { desc = "Find nvim config files" })

-- Git integration
if vim.fn.executable("git") == 1 then
  map("n", "<Leader>gfb", function() require("fzf-lua").git_branches() end, { desc = "Git branches" })
  map("n", "<Leader>gfc", function() require("fzf-lua").git_commits() end, { desc = "Git commits (repository)" })
  map("n", "<Leader>gfC", function() require("fzf-lua").git_bcommits() end, { desc = "Git commits (current file)" })
  map("n", "<Leader>gfs", function() require("fzf-lua").git_status() end, { desc = "Git status" })
end

-- LSP integration (will be enhanced when which-key is migrated)
map("n", "<Leader>lD", function() require("fzf-lua").diagnostics_document() end, { desc = "Search diagnostics" })
map("n", "<Leader>ls", function() require("fzf-lua").lsp_document_symbols() end, { desc = "Search symbols" })

-- Override default LSP keymaps if fzf-lua is available
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    -- Override gd, gri, grr, gy if they exist
    local opts = { noremap = true, silent = true }
    map("n", "gd", function() require("fzf-lua").lsp_definitions() end, opts)
    map("n", "gri", function() require("fzf-lua").lsp_implementations() end, opts)
    map("n", "grr", function() require("fzf-lua").lsp_references() end, opts)
    map("n", "gy", function() require("fzf-lua").lsp_typedefs() end, opts)
    map("n", "<Leader>lG", function() require("fzf-lua").lsp_workspace_symbols() end, opts)
  end,
})