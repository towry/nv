-- nvim-lint configuration for asynchronous linting
-- Provides comprehensive linting for various file types with project-specific configurations

local M = {}

-- Initialize autolint setting
if vim.g.autolint == nil then
  vim.g.autolint = true
end

-- Helper functions for project detection
local function has_file(file)
  return vim.fn.filereadable(vim.fn.findfile(file, '.;')) == 1
end

local function has_files(files)
  for _, file in ipairs(files) do
    if has_file(file) then
      return true
    end
  end
  return false
end

local function get_project_root()
  return vim.fn.fnamemodify(vim.fn.findfile('.git', '.;'), ':h')
end

local function is_large_file()
  local size = vim.fn.getfsize(vim.fn.expand('%:p'))
  return size > 100 * 1024 -- 100KB threshold
end

-- Helper to detect project types
local function detect_project_type()
  local root = get_project_root()

  -- React detection
  if has_files({'package.json'}) then
    local package_json = root .. '/package.json'
    if vim.fn.filereadable(package_json) == 1 then
      local content = vim.fn.readfile(package_json)
      local pkg_content = table.concat(content, '\n')
      if pkg_content:match('"react"') or pkg_content:match('"react%-dom"') then
        return 'react'
      end
    end
  end

  -- Node.js detection
  if has_files({'package.json'}) then
    return 'node'
  end

  -- Python project detection
  if has_files({'pyproject.toml', 'setup.py', 'requirements.txt', 'Pipfile'}) then
    return 'python'
  end

  -- Neovim config detection
  if root:match('%.config/nvim') or has_files({'init.lua'}) then
    return 'neovim'
  end

  return 'unknown'
end

-- nvim-lint configuration
M.config = {
  -- Linters by filetype (dynamically built based on available executables)
  linters_by_ft = function()
    local linters = {}

    -- JavaScript/TypeScript
    if vim.fn.executable('eslint') == 1 then
      linters.javascript = { 'eslint' }
      linters.javascriptreact = { 'eslint' }
      linters.typescript = { 'eslint' }
      linters.typescriptreact = { 'eslint' }
    end

    -- Python
    if vim.fn.executable('flake8') == 1 then
      linters.python = { 'flake8' }
    end

    -- Shell scripts
    if vim.fn.executable('shellcheck') == 1 then
      linters.sh = { 'shellcheck' }
      linters.bash = { 'shellcheck' }
      linters.zsh = { 'shellcheck' }
    end

    -- Web technologies
    if vim.fn.executable('stylelint') == 1 then
      linters.css = { 'stylelint' }
      linters.scss = { 'stylelint' }
      linters.sass = { 'stylelint' }
      linters.less = { 'stylelint' }
    end

    -- Other common file types
    if vim.fn.executable('jsonlint') == 1 then
      linters.json = { 'jsonlint' }
    end

    if vim.fn.executable('yamllint') == 1 then
      linters.yaml = { 'yamllint' }
    end

    if vim.fn.executable('markdownlint') == 1 then
      linters.markdown = { 'markdownlint' }
    end

    if vim.fn.executable('taplo') == 1 then
      linters.toml = { 'taplo' }
    end

    -- Additional file types
    if vim.fn.executable('vint') == 1 then
      linters.vim = { 'vint' }
    end

    return linters
  end,

  -- Custom linter configurations (simplified for stability)
  linters = {
    -- Configure eslint
    eslint = {
      args = {
        '--format', 'compact',
        '--stdin',
        '--stdin-filename', '%:t',
      },
      stream = 'stdout',
      ignore_exitcode = true,
      condition = function()
        return vim.fn.executable('eslint') == 1
      end,
    },

    -- Configure flake8
    flake8 = {
      args = {
        '--format=compact',
        '--stdin-display-name=%:t',
        '-',
      },
      stream = 'stdout',
      ignore_exitcode = true,
      condition = function()
        return vim.fn.executable('flake8') == 1
      end,
    },

    -- Configure shellcheck
    shellcheck = {
      args = {
        '--format=gcc',
        '--severity=warning',
        '--shell=bash',
        '%:p'
      },
      stream = 'stdout',
      ignore_exitcode = true,
      condition = function()
        return vim.fn.executable('shellcheck') == 1
      end,
    },

    -- Configure stylelint
    stylelint = {
      args = {
        '--formatter', 'compact',
        '--stdin-filename', '%:t'
      },
      stream = 'stdout',
      ignore_exitcode = true,
      condition = function()
        return vim.fn.executable('stylelint') == 1
      end,
    },

    -- Configure markdownlint
    markdownlint = {
      args = {
        '--config', vim.fn.stdpath('config') .. '/.markdownlint.json',
        '%:p'
      },
      stream = 'stdout',
      ignore_exitcode = true,
      condition = function()
        return vim.fn.executable('markdownlint') == 1
      end,
    },
  },
}

-- Setup commands
M.setup_commands = function()
  vim.api.nvim_create_user_command("Lint", function()
    local ok, lint = pcall(require, "lint")
    if not ok then
      vim.notify("nvim-lint not available", vim.log.levels.ERROR)
      return
    end

    -- Check if file is too large
    if is_large_file() then
      vim.notify("File too large for linting (>100KB)", vim.log.levels.WARN)
      return
    end

    lint.try_lint()
  end, {
    desc = "Run linter on current buffer",
  })

  vim.api.nvim_create_user_command("LintInfo", function()
    local ok, lint = pcall(require, "lint")
    if not ok then
      vim.notify("nvim-lint not available", vim.log.levels.ERROR)
      return
    end

    local ft = vim.bo.filetype
    local linters = lint.linters_by_ft[ft] or {}
    local project_type = detect_project_type()

    if linters and #linters > 0 then
      local info = string.format("Linters for %s: %s", ft, table.concat(linters, ", "))
      if project_type ~= 'unknown' then
        info = info .. string.format(" (Project: %s)", project_type)
      end
      vim.notify(info, vim.log.levels.INFO)
    else
      vim.notify(string.format("No linters configured for %s", ft), vim.log.levels.WARN)
    end
  end, {
    desc = "Show linter information for current filetype",
  })

  vim.api.nvim_create_user_command("LintProjectInfo", function()
    local project_type = detect_project_type()
    local root = get_project_root()

    local info = string.format("Project Type: %s\nRoot: %s", project_type, root)

    -- Check for config files
    local configs = {}
    if has_file('package.json') then table.insert(configs, 'package.json') end
    if has_file('pyproject.toml') then table.insert(configs, 'pyproject.toml') end
    if has_file('setup.cfg') then table.insert(configs, 'setup.cfg') end
    if has_file('.eslintrc.js') then table.insert(configs, '.eslintrc.js') end
    if has_file('.luacheckrc') then table.insert(configs, '.luacheckrc') end

    if #configs > 0 then
      info = info .. "\nConfig files: " .. table.concat(configs, ", ")
    end

    vim.notify(info, vim.log.levels.INFO)
  end, {
    desc = "Show project information and detected configs",
  })
end

-- Setup keymaps
M.setup_keymaps = function()
  -- Normal mode mappings
  vim.keymap.set("n", "<leader>ll", function()
    vim.cmd.Lint()
  end, { desc = "Run linter" })

  vim.keymap.set("n", "<leader>li", function()
    vim.cmd.LintInfo()
  end, { desc = "Show linter info" })

  vim.keymap.set("n", "<leader>ul", function()
    if vim.b.autolint == nil then
      if vim.g.autolint == nil then
        vim.g.autolint = true
      end
      vim.b.autolint = vim.g.autolint
    end
    vim.b.autolint = not vim.b.autolint

    local status = vim.b.autolint and "on" or "off"
    vim.notify(string.format("Buffer autolinting %s", status), vim.log.levels.INFO)
  end, { desc = "Toggle autolinting (buffer)" })

  vim.keymap.set("n", "<leader>uL", function()
    if vim.g.autolint == nil then
      vim.g.autolint = true
    end
    vim.g.autolint = not vim.g.autolint
    vim.b.autolint = nil

    local status = vim.g.autolint and "on" or "off"
    vim.notify(string.format("Global autolinting %s", status), vim.log.levels.INFO)
  end, { desc = "Toggle autolinting (global)" })
end

-- Setup which-key integration
M.setup_whichkey = function()
  local wk_ok, which_key = pcall(require, "which-key")
  if not wk_ok then
    return
  end

  which_key.add({
    { "<leader>l", group = "LSP", icon = { icon = "λ", color = "purple" } },
    { "<leader>ll", desc = "Run linter" },
    { "<leader>li", desc = "Show linter info" },
    { "<leader>lp", desc = "Show project info" },
    { "<leader>u", group = "UI/Toggles", icon = { icon = "󱠇", color = "cyan" } },
    { "<leader>ul", desc = "Toggle autolinting (buffer)" },
    { "<leader>uL", desc = "Toggle autolinting (global)" },
  })
end

-- Setup autocommands for linting
M.setup_autocmds = function()
  local lint_augroup = vim.api.nvim_create_augroup("linting", { clear = true })

  -- Auto-lint on save (only)
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = lint_augroup,
    callback = function()
      local ok, lint = pcall(require, "lint")
      if not ok then
        return
      end

      -- Check if autolinting is enabled
      local autolint = vim.b.autolint
      if autolint == nil then
        autolint = vim.g.autolint
      end

      if autolint then
        -- Skip in diff mode and for large files
        if not vim.wo[0].diff and not is_large_file() then
          -- Debounce linting to avoid performance issues
          local debounce_timer = vim.b.lint_debounce_timer
          if debounce_timer then
            vim.fn.timer_stop(debounce_timer)
          end

          vim.b.lint_debounce_timer = vim.fn.timer_start(500, function()
            lint.try_lint()
            vim.b.lint_debounce_timer = nil
          end)
        end
      end
    end,
    desc = "Auto-lint on save (debounced)",
  })
end

-- Create default markdownlint config if it does not exist
M.create_default_configs = function()
  local config_path = vim.fn.stdpath('config') .. '/.markdownlint.json'

  if vim.fn.filereadable(config_path) == 0 then
    local default_config = {
      default = true,
      MD013 = {
        line_length = 120,
        code_blocks = false,
        tables = false
      },
      MD033 = {
        allowed_elements = {"br", "sub", "sup"}
      }
    }

    local config_content = vim.json.encode(default_config)
    local file = io.open(config_path, 'w')
    if file then
      file:write(config_content)
      file:close()
    end
  end
end

-- Main setup function
M.setup = function()
  local lint_ok, lint = pcall(require, "lint")
  if not lint_ok then
    return
  end

  -- Create default configuration files
  M.create_default_configs()

  -- Setup nvim-lint by directly assigning configuration
  -- Note: nvim-lint doesn't have a setup() method, we assign directly to its tables
  lint.linters_by_ft = M.config.linters_by_ft()

  -- Merge custom linter configurations with existing ones
  for linter_name, linter_config in pairs(M.config.linters) do
    if not lint.linters[linter_name] then
      lint.linters[linter_name] = {}
    end
    for key, value in pairs(linter_config) do
      lint.linters[linter_name][key] = value
    end
  end

  -- Setup commands, keymaps, and autocmds
  M.setup_commands()
  M.setup_keymaps()
  M.setup_whichkey()
  M.setup_autocmds()

  -- Notify about setup completion
  vim.notify("nvim-lint configured with project-specific settings", vim.log.levels.INFO)
end

return M
