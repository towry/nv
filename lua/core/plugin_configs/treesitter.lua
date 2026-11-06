-- Treesitter configuration (nvim-treesitter main branch)
--
-- The main branch only ships parsers and queries. Highlighting is a Neovim
-- feature that has to be started per buffer. Neovim's own ftplugins do this
-- only for lua, vim, vimdoc and query, so start it for every filetype that
-- has an installed parser. Install new parsers with `:TSInstall <lang>`.

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
