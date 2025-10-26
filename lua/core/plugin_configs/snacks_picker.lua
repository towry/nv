-- Snacks.nvim picker keybindings
-- Implements all picker keybindings for snacks.nvim migration from fzf-lua

local ok, snacks = pcall(require, "snacks")
if not ok then
	vim.notify("snacks.nvim not found, skipping picker keybindings", vim.log.levels.WARN)
	return
end

-- Helper function to extract visual selection text
-- From design.md section "Visual Selection Helper"
local function get_visual_selection()
	local mode = vim.fn.mode()
	if mode == "v" or mode == "V" or mode == "" then
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")
		local lines = vim.fn.getline(start_pos[2], end_pos[2])
		if #lines == 0 then
			return ""
		end

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

-- Helper function to check if executable is available
local function is_executable(cmd)
	return vim.fn.executable(cmd) == 1
end

-- Helper function to check if in git repository
local function is_git_repo()
	return vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):gsub("%s+", "") == "true"
end

-- Helper function to check if LSP is attached
local function has_lsp_client()
	return #vim.lsp.get_active_clients({ bufnr = 0 }) > 0
end

-- P1.4: Core Pickers (Files, Buffers, Grep)
----------------------------------------------

-- 1. <Leader>ff: Files picker in CWD
vim.keymap.set("n", "<Leader>ff", function()
	snacks.picker.files({ cwd = vim.fn.getcwd() })
end, { desc = "Files (CWD)" })

-- 2. <Leader>fB: Buffers picker
vim.keymap.set("n", "<Leader>fB", function()
	snacks.picker.buffers({
		-- Show filename first for better readability
		formatters = { file = { filename_first = true } },
	})
end, { desc = "Buffers" })

-- 3. <Leader>fo: Recent files (CWD only)
vim.keymap.set("n", "<Leader>fo", function()
	snacks.picker.recent({
		cwd = vim.fn.getcwd(),
		filter = { cwd = vim.fn.getcwd() },
	})
end, { desc = "Recent files (CWD)" })

-- 4. <Leader>fl and <Leader>f<CR>: Resume last picker
vim.keymap.set("n", "<Leader>fl", function()
	snacks.picker.resume()
end, { desc = "Resume last picker" })

vim.keymap.set("n", "<Leader>f<CR>", function()
	snacks.picker.resume()
end, { desc = "Resume last picker" })

-- 5. <localleader>,: Recent files/buffers
vim.keymap.set("n", "<localleader>,", function()
	snacks.picker.recent()
end, { desc = "Recent files/buffers" })

-- 6. <Leader>fXa: Config files picker
vim.keymap.set("n", "<Leader>fXa", function()
	snacks.picker.files({
		cwd = vim.fn.stdpath("config"),
		title = "Config Files",
	})
end, { desc = "Config files" })

-- 7. <Leader>fg (normal): Live grep in CWD
vim.keymap.set("n", "<Leader>fg", function()
	if is_executable("rg") then
		snacks.picker.grep({
			live = true,
			cwd = vim.fn.getcwd(),
		})
	else
		vim.notify("ripgrep not found. Please install ripgrep for live grep.", vim.log.levels.WARN)
	end
end, { desc = "Live grep" })

-- 8. <Leader>fs: Live grep (search as you type)
vim.keymap.set("n", "<Leader>fs", function()
	if is_executable("rg") then
		snacks.picker.grep({
			live = true,
			cwd = vim.fn.getcwd(),
		})
	else
		vim.notify("ripgrep not found. Please install ripgrep for grep.", vim.log.levels.WARN)
	end
end, { desc = "Live grep" })

-- 9. <Leader>fg (visual): Grep with visual selection
vim.keymap.set("v", "<Leader>fg", function()
	local selection = get_visual_selection()
	if selection and selection ~= "" then
		if is_executable("rg") then
			-- Exit visual mode first
			vim.cmd("normal! " .. vim.fn.mode() == "V" and "V" or "v")
			snacks.picker.grep({
				live = true,
				search = selection,
				cwd = vim.fn.getcwd(),
			})
		else
			vim.notify("ripgrep not found. Please install ripgrep for grep.", vim.log.levels.WARN)
		end
	else
		vim.notify("No visual selection found", vim.log.levels.WARN)
	end
end, { desc = "Grep selection" })

-- 10. <Leader>fc: Grep word under cursor
vim.keymap.set("n", "<Leader>fc", function()
	if is_executable("rg") then
		snacks.picker.grep_word({
			cwd = vim.fn.getcwd(),
		})
	else
		vim.notify("ripgrep not found. Please install ripgrep for grep.", vim.log.levels.WARN)
	end
end, { desc = "Grep word under cursor" })

-- 11. <Leader>fb: Grep in current buffer
vim.keymap.set("n", "<Leader>fb", function()
	if is_executable("rg") then
		snacks.picker.grep({
			filter = { buf = 0 },
			cwd = vim.fn.getcwd(),
		})
	else
		vim.notify("ripgrep not found. Please install ripgrep for grep.", vim.log.levels.WARN)
	end
end, { desc = "Grep in buffer" })

-- 12. <Leader>f/: Live grep in current buffer
vim.keymap.set("n", "<Leader>f/", function()
	if is_executable("rg") then
		snacks.picker.grep({
			live = true,
			filter = { buf = 0 },
			cwd = vim.fn.getcwd(),
		})
	else
		vim.notify("ripgrep not found. Please install ripgrep for grep.", vim.log.levels.WARN)
	end
end, { desc = "Live grep in buffer" })

-- P1.5: Git Pickers
-------------------

-- 1. <Leader>gfb: Git branches
vim.keymap.set("n", "<Leader>gfb", function()
	if is_executable("git") and is_git_repo() then
		snacks.picker.git_branches()
	else
		vim.notify("Not in a git repository or git not found", vim.log.levels.WARN)
	end
end, { desc = "Git branches" })

-- 2. <Leader>gfc: Git commits (repo)
vim.keymap.set("n", "<Leader>gfc", function()
	if is_executable("git") and is_git_repo() then
		snacks.picker.git_log()
	else
		vim.notify("Not in a git repository or git not found", vim.log.levels.WARN)
	end
end, { desc = "Git commits (repo)" })

-- 3. <Leader>gfC: Git commits (current file)
vim.keymap.set("n", "<Leader>gfC", function()
	if is_executable("git") and is_git_repo() then
		snacks.picker.git_log_file()
	else
		vim.notify("Not in a git repository or git not found", vim.log.levels.WARN)
	end
end, { desc = "Git commits (file)" })

-- 4. <Leader>gfs: Git status
vim.keymap.set("n", "<Leader>gfs", function()
	if is_executable("git") and is_git_repo() then
		snacks.picker.git_status()
	else
		vim.notify("Not in a git repository or git not found", vim.log.levels.WARN)
	end
end, { desc = "Git status" })

-- P1.6: LSP Pickers
-------------------

-- 1. gd: LSP definitions (auto-confirm if single result)
vim.keymap.set("n", "gd", function()
	if has_lsp_client() then
		snacks.picker.lsp_definitions({ auto_confirm = true })
	else
		vim.notify("No LSP client attached", vim.log.levels.WARN)
	end
end, { desc = "Go to definition" })

-- 2. grr: LSP references
vim.keymap.set("n", "grr", function()
	if has_lsp_client() then
		snacks.picker.lsp_references()
	else
		vim.notify("No LSP client attached", vim.log.levels.WARN)
	end
end, { desc = "LSP references" })

-- 3. gri: LSP implementations
vim.keymap.set("n", "gri", function()
	if has_lsp_client() then
		snacks.picker.lsp_implementations()
	else
		vim.notify("No LSP client attached", vim.log.levels.WARN)
	end
end, { desc = "LSP implementations" })

-- 4. gy: LSP type definitions
vim.keymap.set("n", "gy", function()
	if has_lsp_client() then
		snacks.picker.lsp_type_definitions()
	else
		vim.notify("No LSP client attached", vim.log.levels.WARN)
	end
end, { desc = "LSP type definitions" })

-- 5. <Leader>ls: Document symbols
vim.keymap.set("n", "<Leader>ls", function()
	if has_lsp_client() then
		snacks.picker.lsp_symbols()
	else
		vim.notify("No LSP client attached", vim.log.levels.WARN)
	end
end, { desc = "Document symbols" })

-- 6. <Leader>lS and <Leader>lG: Workspace symbols
vim.keymap.set("n", "<Leader>lS", function()
	if has_lsp_client() then
		snacks.picker.lsp_workspace_symbols()
	else
		vim.notify("No LSP client attached", vim.log.levels.WARN)
	end
end, { desc = "Workspace symbols" })

vim.keymap.set("n", "<Leader>lG", function()
	if has_lsp_client() then
		snacks.picker.lsp_workspace_symbols()
	else
		vim.notify("No LSP client attached", vim.log.levels.WARN)
	end
end, { desc = "Workspace symbols" })

-- 7. <Leader>lD: Document diagnostics
vim.keymap.set("n", "<Leader>lD", function()
	snacks.picker.diagnostics_buffer()
end, { desc = "Document diagnostics" })

-- P1.7: Utility Pickers
-----------------------

-- 1. <Leader>fq: Quickfix list
vim.keymap.set("n", "<Leader>fq", function()
	snacks.picker.quickfix()
end, { desc = "Quickfix list" })

-- 2. <Leader>fj: Jumplist
vim.keymap.set("n", "<Leader>fj", function()
	snacks.picker.jumps()
end, { desc = "Jumplist" })

-- 3. <Leader>f': Marks
vim.keymap.set("n", "<Leader>f'", function()
	snacks.picker.marks()
end, { desc = "Marks" })

-- 4. <Leader>fr: Registers
vim.keymap.set("n", "<Leader>fr", function()
	snacks.picker.registers()
end, { desc = "Registers" })

-- 5. <Leader>f;: Command history
vim.keymap.set("n", "<Leader>f;", function()
	snacks.picker.command_history()
end, { desc = "Command history" })

-- 6. <Leader>f:: Commands
vim.keymap.set("n", "<Leader>f:", function()
	snacks.picker.commands()
end, { desc = "Commands" })

-- 7. <Leader>fh: Help tags
vim.keymap.set("n", "<Leader>fh", function()
	snacks.picker.help()
end, { desc = "Help tags" })

-- 8. <Leader>fk: Keymaps
vim.keymap.set("n", "<Leader>fk", function()
	snacks.picker.keymaps()
end, { desc = "Keymaps" })

-- 9. <Leader>fm: Man pages
vim.keymap.set("n", "<Leader>fm", function()
	snacks.picker.man()
end, { desc = "Man pages" })

-- 10. <Leader>f.: Picker of pickers (main selector)
vim.keymap.set("n", "<Leader>f.", function()
	-- Show a picker with all available pickers
	local pickers = {
		{
			text = "Files",
			action = function()
				snacks.picker.files()
			end,
		},
		{
			text = "Buffers",
			action = function()
				snacks.picker.buffers()
			end,
		},
		{
			text = "Recent",
			action = function()
				snacks.picker.recent()
			end,
		},
		{
			text = "Live Grep",
			action = function()
				if is_executable("rg") then
					snacks.picker.grep({ live = true })
				else
					vim.notify("ripgrep not found", vim.log.levels.WARN)
				end
			end,
		},
		{
			text = "Git Status",
			action = function()
				if is_executable("git") and is_git_repo() then
					snacks.picker.git_status()
				else
					vim.notify("Not in git repo", vim.log.levels.WARN)
				end
			end,
		},
		{
			text = "LSP Symbols",
			action = function()
				if has_lsp_client() then
					snacks.picker.lsp_symbols()
				else
					vim.notify("No LSP client", vim.log.levels.WARN)
				end
			end,
		},
		{
			text = "Help",
			action = function()
				snacks.picker.help()
			end,
		},
		{
			text = "Commands",
			action = function()
				snacks.picker.commands()
			end,
		},
	}

	vim.ui.select(pickers, {
		prompt = "Select picker:",
		format_item = function(item)
			return item.text
		end,
	}, function(choice)
		if choice then
			choice.action()
		end
	end)
end, { desc = "Picker of pickers" })

-- Custom Folder Picker for Oil Explorer
-- Opens a picker to select a folder from the current project and open it with Oil
vim.keymap.set("n", "<Leader>fd", function()
	local cwd = vim.fn.getcwd()
	local items = {}

	-- Scan directories recursively with depth limit
	local function scan_dir(dir, depth)
		if depth > 3 then
			return
		end -- Limit depth to avoid too many results

		local handle = vim.loop.fs_scandir(dir)
		if not handle then
			return
		end

		while true do
			local name, type = vim.loop.fs_scandir_next(handle)
			if not name then
				break
			end

			-- Skip hidden directories and common ignore patterns
			if
				type == "directory"
				and not name:match("^%.")
				and name ~= "node_modules"
				and name ~= ".git"
				and name ~= "__pycache__"
			then
				local full_path = dir .. "/" .. name
				local relative_path = full_path:sub(#cwd + 2)

				table.insert(items, {
					idx = #items + 1,
					score = #items + 1,
					text = relative_path,
					path = full_path,
				})

				-- Recursively scan subdirectories
				scan_dir(full_path, depth + 1)
			end
		end
	end

	-- Scan current directory
	scan_dir(cwd, 1)

	if #items == 0 then
		vim.notify("No directories found", vim.log.levels.WARN)
		return
	end

	-- Create the picker
	snacks.picker({
		items = items,
		format = function(item)
			return { { item.text, "SnacksPickerDir" } }
		end,
		confirm = function(picker, item)
			picker:close()
			-- Open the selected directory with Oil
			local ok_oil, oil = pcall(require, "oil")
			if ok_oil then
				oil.open(item.path)
			else
				vim.notify("Oil not found", vim.log.levels.ERROR)
			end
		end,
	})
end, { desc = "Folders → Oil" })

vim.api.nvim_set_hl(0, "SnacksPickerDir", { link = "Special" })
vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { link = "Text" })
vim.api.nvim_set_hl(0, "SnacksPickerPathIgnored", { link = "Comment" })
vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { link = "Special" })
