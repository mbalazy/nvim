-- Transparent tabline/statusline backgrounds (bufferline draws into the
-- tabline, so its highlights are overridden here after every colorscheme load).
vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
	group = vim.api.nvim_create_augroup("user_clear_bufferline", { clear = true }),
	callback = function()
		vim.cmd([[
      highlight StatusLine guibg=NONE ctermbg=NONE
      highlight StatusLineNC guibg=NONE ctermbg=NONE
      highlight TabLine guibg=NONE ctermbg=NONE
      highlight TabLineFill guibg=NONE ctermbg=NONE
      highlight TabLineSel guibg=NONE ctermbg=NONE
    ]])
	end,
})
