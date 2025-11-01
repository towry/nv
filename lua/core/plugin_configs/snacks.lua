-- Snacks.nvim picker configuration
-- Replaces fzf-lua with snacks.nvim picker functionality

local ok, snacks = pcall(require, "snacks")
if not ok then
	vim.notify("snacks.nvim not found, skipping picker configuration", vim.log.levels.WARN)
	return
end

-- Configure snacks.nvim picker with global settings
snacks.setup({
	bigfile = { enabled = true },
	picker = {
		-- Global picker settings
		prompt = " ",
		focus = "input",
		show_delay = 1000,
		limit_live = 10000,

		-- Adaptive layout: horizontal (preview right) for wide screens, vertical (preview bottom) for narrow
		-- Window dimensions: 85% width, 98% height
		-- Threshold: 180 columns for wide screen detection
		layout = {
			preset = function()
				return vim.o.columns >= 100 and "default" or "vertical"
			end,
			cycle = true,
			width = function()
				return math.floor(vim.o.columns * 0.85)
			end,
			height = function()
				return math.floor(vim.o.lines * 0.98)
			end,
		},

		-- Custom keybindings within picker
		win = {
			input = {
				keys = {
					["<c-q>"] = "select_all+accept",
					["<c-u>"] = "half-page-up",
					["<c-d>"] = "half-page-down",
					["<c-f>"] = "preview_scroll_down",
					["<c-b>"] = "preview_scroll_up",
					["<Tab>"] = "toggle+down",
					["<S-Tab>"] = "toggle+up",
				},
			},
			preview = {
				wo = {
					wrap = true,
				},
			},
		},

		-- Matcher configuration
		matcher = {
			fuzzy = true,
			smartcase = true,
			filename_bonus = true,
		},

		-- Enable vim.ui.select replacement
		ui_select = true,
	},
})

-- Disable completion in prompt buffers (like snacks picker input)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "snacks_picker_input",
	callback = function()
		vim.opt_local.completeopt = ""
		vim.opt_local.omnifunc = ""
	end,
})
