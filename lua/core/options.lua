-- Basic options for performance and usability
local o = vim.opt

o.number = true
o.relativenumber = true
o.winborder = "single"
o.cursorline = true
o.clipboard = "unnamedplus"
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true
o.wrap = true
o.termguicolors = true
o.hidden = true
o.swapfile = false
o.backup = false
o.undodir = vim.fn.stdpath("config") .. "/undo"
o.undofile = true
o.autoread = true

-- shorter update time
o.updatetime = 300

-- split preferences
o.splitright = true
o.splitbelow = true

-- fix alpha blending that exacerbates pink tinting
o.winblend = 0 -- floating windows
o.pumblend = 0 -- completion menu

-- folding with treesitter
o.foldmethod = "expr"
o.foldexpr = "nvim_treesitter#foldexpr()"
o.foldenable = false

-- Fix cursor shape escape sequences in tmux
-- Disable cursor shape changes to prevent \E[2 q artifacts
o.guicursor = ""

return {}
