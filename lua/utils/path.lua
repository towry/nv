-- Utilities for computing and copying file and directory paths
-- Works with Neovim buffers and uses the OS clipboard via registers +/-/*

---@class FilePathUtil
---@field get_absolute_path fun(filepath: string|nil): string
---@field get_relative_path fun(filepath: string|nil): string
---@field get_directory_path fun(filepath: string|nil, relative: boolean?): string
---@field copy_to_clipboard fun(text: string): nil

local M = {}

---Get an absolute file path for a given filepath or current buffer
---@param filepath string|nil
---@return string
function M.get_absolute_path(filepath)
  local path = filepath or vim.fn.expand('%:p')
  if not path or path == '' or path == nil then
    return ''
  end

  -- Normalize: return a string; no tilde expansion or such needed for now
  return path
end

---Get a path relative to current working directory (or return absolute if not inside cwd)
---@param filepath string|nil
---@param cwd string|nil
---@return string
function M.get_relative_path(filepath, cwd)
  local abs = M.get_absolute_path(filepath)
  if abs == '' then
    return ''
  end

  cwd = cwd or vim.fn.getcwd()
  if cwd and abs:sub(1, #cwd) == cwd then
    return abs:sub(#cwd + 2) -- +2 to skip the trailing slash
  end
  return abs
end

---Get the parent directory path for a file. If `relative` is true, return relative to CWD
---@param filepath string|nil
---@param relative boolean|nil
---@return string
function M.get_directory_path(filepath, relative)
  local abs = M.get_absolute_path(filepath)
  if abs == '' then
    return ''
  end

  local dir = vim.fn.fnamemodify(abs, ':h')
  if relative then
    return M.get_relative_path(dir)
  end
  return dir
end

---Copy a string to system clipboard and the star register, with a user notification
---@param text string
---@return nil
function M.copy_to_clipboard(text)
  if not text or text == '' then
    vim.notify('Nothing to copy', vim.log.levels.WARN)
    return
  end

  -- Use both selection and clipboard registers for better compatibility
  vim.fn.setreg('+', text)
  vim.fn.setreg('*', text)
  vim.notify('Copied to clipboard: ' .. text, vim.log.levels.INFO)
end

return M
