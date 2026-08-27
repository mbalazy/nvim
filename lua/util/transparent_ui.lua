-- Transparent statusline/tabline backgrounds, re-applied after every colorscheme load.
vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
	group = vim.api.nvim_create_augroup("user_transparent_ui", { clear = true }),
	callback = function()
		vim.cmd([[
      highlight StatusLine guibg=NONE ctermbg=NONE
      highlight StatusLineNC guibg=NONE ctermbg=NONE
      highlight TabLine guibg=NONE ctermbg=NONE
      highlight TabLineFill guibg=NONE ctermbg=NONE
      highlight TabLineSel guibg=NONE ctermbg=NONE
      highlight MiniTablineFill guibg=NONE ctermbg=NONE
      highlight MiniTablineCurrent guibg=NONE ctermbg=NONE gui=bold
      highlight MiniTablineVisible guibg=NONE ctermbg=NONE
      highlight MiniTablineHidden guibg=NONE ctermbg=NONE
      highlight MiniTablineModifiedCurrent guibg=NONE ctermbg=NONE gui=bold
      highlight MiniTablineModifiedVisible guibg=NONE ctermbg=NONE
      highlight MiniTablineModifiedHidden guibg=NONE ctermbg=NONE
    ]])
	end,
})
