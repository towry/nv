-- Basic options for performance and usability
local o = vim.opt

o.number = true
o.relativenumber = false
o.cursorline = true
o.clipboard = 'unnamedplus'
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true
o.wrap = false
o.termguicolors = true
o.hidden = true
o.swapfile = false
o.backup = false
o.undodir = vim.fn.stdpath('config') .. '/undo'
o.undofile = true

-- shorter update time
o.updatetime = 300

-- split preferences
o.splitright = true
o.splitbelow = true

return {}
