-- Treesitter configuration (nvim-treesitter main branch)
--
-- The main branch only ships parsers and queries. Highlighting is a Neovim
-- feature that has to be started per buffer. Neovim's own ftplugins do this
-- only for lua, vim, vimdoc and query, so start it for every filetype that
-- has an installed parser. Install new parsers with `:TSInstall <lang>`.

-- Queries live in the plugin's runtime/queries and are only linked into
-- install_dir by install(). Put them on the runtimepath directly so parsers
-- already on disk highlight without a network install.
local pack = vim.pack.get({ 'nvim-treesitter' })
local ts_root = pack and pack[1] and pack[1].path
if ts_root and vim.uv.fs_stat(ts_root .. '/runtime/queries') then
  vim.opt.rtp:append(ts_root .. '/runtime')
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter_start', { clear = true }),
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if not lang then
      return
    end
    pcall(vim.treesitter.start, args.buf, lang)
  end,
})
