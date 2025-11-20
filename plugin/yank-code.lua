-- Yank code block with file path and line numbers
-- Usage: Select text in visual mode and run :YankCode

---@class YankCodeUtil
---@field yank_code fun(): nil
---@field get_file_extension fun(filepath: string): string
---@field get_relative_path fun(filepath: string): string
local M = {}

-- Get the file extension for syntax highlighting
---@param filepath string
---@return string
local function get_file_extension(filepath)
  local ext = filepath:match("%.([^%.]+)$")
  if not ext then
    return "txt"
  end

  -- Map common extensions to their syntax highlighting names
  ---@type table<string, string>
  local ext_map = {
    js = "javascript",
    ts = "typescript",
    jsx = "javascript",
    tsx = "typescript",
    py = "python",
    rb = "ruby",
    sh = "bash",
    zsh = "bash",
    fish = "bash",
    yml = "yaml",
    md = "markdown",
    rs = "rust",
    go = "go",
    c = "c",
    cpp = "cpp",
    h = "c",
    hpp = "cpp",
    java = "java",
    kt = "kotlin",
    swift = "swift",
    php = "php",
    html = "html",
    css = "css",
    scss = "scss",
    sass = "sass",
    less = "less",
    vue = "vue",
    svelte = "svelte",
    ex = "elixir",
    exs = "elixir",
    eex = "elixir",
    heex = "elixir",
    lua = "lua",
    vim = "vim",
    json = "json",
    xml = "xml",
    sql = "sql",
    r = "r",
    R = "r",
    jl = "julia",
    scala = "scala",
    clj = "clojure",
    cljs = "clojure",
    hs = "haskell",
    elm = "elm",
    dart = "dart",
    nix = "nix",
  }

  return ext_map[ext] or ext
end

-- Get relative path from current working directory
---@param filepath string
---@return string
local function get_relative_path(filepath)
  local cwd = vim.fn.getcwd()
  if filepath:sub(1, #cwd) == cwd then
    local relative = filepath:sub(#cwd + 2) -- +2 to skip the trailing slash
    return relative
  end
  return filepath
end

-- Main function to yank code block
---@param opts table|nil Options table with absolute_path boolean
---@return nil
function M.yank_code(opts)
  opts = opts or {}
  local use_absolute_path = opts.absolute_path or false

  -- Get visual selection range
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  -- Get current file path
  local filepath = vim.fn.expand("%:p")
  local display_path = use_absolute_path and filepath or get_relative_path(filepath)

  -- Get selected text
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local selected_text = table.concat(lines, "\n")

  -- Get file extension for syntax highlighting
  local file_ext = get_file_extension(display_path)

  -- Format the output
  local output = string.format("%s:L%d-L%d\n\n```%s\n%s\n```",
    display_path,
    start_line,
    end_line,
    file_ext,
    selected_text
  )

  -- Copy to clipboard
  vim.fn.setreg("+", output)
  vim.fn.setreg("*", output) -- Also set the selection register for compatibility

  -- Show notification
  local path_type = use_absolute_path and "absolute" or "relative"
  vim.notify(string.format("Yanked %d lines from %s %s (L%d-L%d)",
    end_line - start_line + 1,
    path_type,
    display_path,
    start_line,
    end_line),
    vim.log.levels.INFO
  )
end

-- Create the commands
vim.api.nvim_create_user_command("YankCode", function()
  M.yank_code({ absolute_path = false })
end, {
  desc = "Yank selected code block with relative file path and line numbers",
  range = true, -- Allow range selection
})

vim.api.nvim_create_user_command("YankCodeAbs", function()
  M.yank_code({ absolute_path = true })
end, {
  desc = "Yank selected code block with absolute file path and line numbers",
  range = true, -- Allow range selection
})

-- Register commands individually with legendary (no nested groups)
require('utils.legendary').register({
  commands = {
    {
      ':YankCopyFilePath',
      description = 'Copy current buffer absolute file path to clipboard',
    },
    {
      ':YankCopyFileRelPath',
      description = 'Copy current buffer relative file path to clipboard',
    },
    {
      ':YankCopyFileDir',
      description = 'Copy current buffer directory path to clipboard',
    },
    {
      ':YankCode',
      description = '󰆏 YankCode: Copy selected code with relative file path and line numbers (visual mode)',
    },
    {
      ':YankCodeAbs',
      description = '󰆏 YankCode [Abs]: Copy selected code with absolute file path and line numbers (visual mode)',
    },
  },
  keymaps = {
    {
      '<leader>yp',
      ':YankCopyFilePath<CR>',
      description = 'Copy current file absolute path',
      mode = { 'n' },
    },
    {
      '<leader>yr',
      ':YankCopyFileRelPath<CR>',
      description = 'Copy current file relative path',
      mode = { 'n' },
    },
    {
      '<leader>yd',
      ':YankCopyFileDir<CR>',
      description = 'Copy current file directory',
      mode = { 'n' },
    },
    {
      '<leader>yc',
      ':YankCode<CR>',
      description = '󰆏 YankCode: Copy code with relative path',
      mode = { 'x' }, -- visual/select mode
    },
    {
      '<leader>yC',
      ':YankCodeAbs<CR>',
      description = '󰆏 YankCode [Abs]: Copy code with absolute path',
      mode = { 'x' }, -- visual/select mode
    },
  },
})

-- Commands for copying file path/directory

---Copy absolute path of current buffer
vim.api.nvim_create_user_command('YankCopyFilePath', function()
  local path = vim.fn.expand('%:p')
  require('utils.path').copy_to_clipboard(path)
end, { desc = 'Copy absolute file path to clipboard' })

---Copy relative path of current buffer (relative to CWD)
vim.api.nvim_create_user_command('YankCopyFileRelPath', function()
  local path = vim.fn.expand('%:p')
  local rel = require('utils.path').get_relative_path(path)
  require('utils.path').copy_to_clipboard(rel)
end, { desc = 'Copy relative file path to clipboard' })

---Copy directory of current buffer
vim.api.nvim_create_user_command('YankCopyFileDir', function()
  local path = vim.fn.expand('%:p')
  local dir = require('utils.path').get_directory_path(path)
  require('utils.path').copy_to_clipboard(dir)
end, { desc = 'Copy buffer directory path to clipboard' })

return M
