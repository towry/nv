-- fzf-lua custom pickers
local M = {}

function M.get_last_query()
  local fzflua = require("fzf-lua")
  return vim.trim(fzflua.config.__resume_data.last_query or "")
end

-- Enhanced grep with rgflow integration (simplified)
local function callgrep(opts, callfn)
  local fzflua = require("fzf-lua")
  opts = vim.tbl_deep_extend("force", {}, opts)
  
  opts.cwd_header = true
  if not opts.cwd then opts.cwd = vim.fn.getcwd() end
  opts.no_header = false
  opts.formatter = "path.filename_first"
  opts.rg_opts = opts.rg_opts
    or [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --fixed-strings --]]

  return callfn(opts)
end

function M.grep(opts, is_live)
  opts = opts or {}
  if is_live == nil then is_live = true end
  local fzflua = require("fzf-lua")

  if is_live then
    opts.prompt = opts.prompt or "󱙓  Live Grep (Fixed) ❯ "
  else
    opts.input_prompt = "󱙓  Grep❯ "
  end
  
  return callgrep(
    opts,
    vim.schedule_wrap(function(opts_local)
      if is_live then
        return fzflua.live_grep(opts_local)
      else
        return fzflua.grep(opts_local)
      end
    end)
  )
end

function M.files(opts)
  opts = opts or {}
  local fzflua = require("fzf-lua")

  if not opts.cwd then opts.cwd = vim.fn.getcwd(-1, 0) end
  opts.winopts = { fullscreen = false }
  opts.ignore_current_file = false

  return fzflua.files(opts)
end

function M.folders(opts)
  opts = opts or {}
  local fzflua = require("fzf-lua")
  local path = require("fzf-lua.path")

  if not opts.cwd then opts.cwd = vim.fn.getcwd(-1, 0) end
  local preview_cwd = opts.cwd

  local cmd = string.format([[fd --color always --type directory --max-depth %s]], opts.max_depth or 4)
  local has_exa = vim.fn.executable("eza") == 1

  opts.prompt = "󰥨  Folders❯ "
  opts.cmd = cmd
  opts.cwd_header = true
  opts.cwd_prompt = true
  opts.toggle_ignore_flag = "--no-ignore-vcs"
  opts.winopts = {
    fullscreen = false,
    width = 0.7,
    height = 0.6,
  }
  opts.fzf_opts = {
    ["--preview-window"] = "nohidden,down,50%",
    ["--preview"] = fzflua.shell.stringify_cmd(function(items)
      if has_exa then
        return string.format(
          "cd %s ; eza --color=always --icons=always --group-directories-first -a %s",
          preview_cwd,
          items[1]
        )
      end
      return string.format("cd %s ; ls %s", preview_cwd, items[1])
    end, opts, "{}"),
  }

  opts.actions = {
    ["default"] = function(selected, selected_opts)
      local first_selected = selected[1]
      if not first_selected then return end
      local entry = path.entry_to_file(first_selected, selected_opts)
      local entry_path = entry.path
      if not entry_path then return end
      
      -- Simple folder action - change directory
      vim.schedule(function()
        vim.cmd("cd " .. entry_path)
        vim.notify("Changed directory to: " .. entry_path)
      end)
    end,
    ["alt-i"] = function(_, o)
      opts.cmd = vim.fn["utils#toggle_cmd_option"](o.cmd, "--no-ignore")
      return fzflua.fzf_exec(opts.cmd, opts)
    end,
    ["alt-h"] = function(_, o)
      opts.cmd = vim.fn["utils#toggle_cmd_option"](o.cmd, "--hidden")
      opts.query = M.get_last_query()
      return fzflua.fzf_exec(opts.cmd, opts)
    end,
  }

  return fzflua.fzf_exec(cmd, opts)
end

function M.buffers_or_recent(no_buffers)
  local fzflua = require("fzf-lua")
  local bufopts = {
    filename_first = true,
    sort_lastused = true,
    show_unloaded = false,
    winopts = {
      height = 0.6,
      fullscreen = false,
      preview = { hidden = "hidden" },
    },
  }
  local oldfiles_opts = {
    prompt = " Recent: ",
    cwd = vim.fn.getcwd(),
    cwd_only = true,
    include_current_session = true,
    winopts = {
      height = 0.6,
      fullscreen = false,
      preview = { hidden = "hidden" },
    },
  }

  local count = #vim.fn.getbufinfo({ buflisted = 1 })
  if no_buffers or count <= 1 then
    fzflua.oldfiles(oldfiles_opts)
    return
  end
  
  return fzflua.buffers(bufopts)
end

function M.git_branches()
  local fzflua = require("fzf-lua")
  local winopts = {
    fullscreen = false,
    width = 0.8,
    height = 0.6,
  }

  fzflua.fzf_exec({
    "Local branches",
    "Remote branches", 
    "All branches",
  }, {
    actions = {
      ["default"] = function(selected)
        if not selected or #selected <= 0 then return end
        if selected[1] == "Local branches" then
          fzflua.git_branches({
            winopts = winopts,
            cmd = "git branch --color",
            prompt = "Local branches❯ ",
          })
        elseif selected[1] == "Remote branches" then
          fzflua.git_branches({
            winopts = winopts,
            cmd = "git branch --remotes --color",
            prompt = "Remote branches❯ ",
          })
        elseif selected[1] == "All branches" then
          fzflua.git_branches({
            winopts = winopts,
            cmd = "git branch --all --color",
            prompt = "All branches❯ ",
          })
        end
      end,
    },
    winopts = winopts,
  })
end

function M.command_history()
  local fzflua = require("fzf-lua")
  fzflua.command_history({
    cwd_only = true,
    winopts = { fullscreen = false },
  })
end

function M.zoxide_folders(opts)
  if vim.fn.executable("zoxide") == 0 then
    vim.notify("zoxide not installed", vim.log.levels.ERROR)
    return
  end
  
  opts = opts or {}
  opts.formatter = "path.filename_first"
  local fzflua = require("fzf-lua")
  local path = require("fzf-lua.path")

  if not opts.cwd then opts.cwd = vim.fn.getcwd(-1, 0) end
  local preview_cwd = opts.cwd

  local cmd = string.format(
    [[zoxide query --list --exclude %s | awk -v home="$HOME" '{gsub("^" home, "~"); print}']],
    vim.env.HOME
  )
  local has_exa = vim.fn.executable("eza") == 1

  opts.prompt = "󰥨  Zoxide ❯ "
  opts.cmd = cmd
  opts.cwd_header = true
  opts.cwd_prompt = true
  opts.winopts = {
    fullscreen = false,
    width = 0.7,
    height = 0.6,
  }
  opts.fzf_opts = {
    ["--tiebreak"] = "index",
    ["--preview-window"] = "nohidden,down,50%",
    ["--preview"] = fzflua.shell.stringify_cmd(function(items)
      local item = (items[1] or ""):gsub("%s%[.*%]$", "")

      if has_exa then
        return string.format(
          "cd %s ; eza --color=always --icons=always --group-directories-first -a %s",
          preview_cwd,
          item
        )
      end
      return string.format("cd %s ; ls %s", preview_cwd, item)
    end, opts, "{}"),
  }

  opts.actions = {
    ["default"] = function(selected, selected_opts)
      local first_selected = selected[1]
      if not first_selected then return end
      local entry = path.entry_to_file(first_selected, selected_opts)
      local entry_path = entry.path
      if not entry_path then return end
      entry_path = entry_path:gsub("%s%[.*%]$", "")
      
      vim.schedule(function()
        vim.cmd("cd " .. entry_path)
        vim.notify("Changed directory to: " .. entry_path)
      end)
    end,
  }

  return fzflua.fzf_exec(cmd, opts)
end

return M