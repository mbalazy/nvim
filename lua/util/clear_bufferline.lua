-- This approach uses winhighlight to completely override the window background
-- without relying on bufferline's own highlight system

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter", "VimEnter", "ColorScheme" }, {
	callback = function()
		-- Find the bufferline window
		local wins = vim.api.nvim_list_wins()
		for _, win in ipairs(wins) do
			local buf = vim.api.nvim_win_get_buf(win)
			local buf_name = vim.api.nvim_buf_get_name(buf)

			-- Check if this is the bufferline buffer
			-- The exact pattern may need adjustment depending on how bufferline names its buffer
			if buf_name:match("bufferline") or vim.bo[buf].filetype == "bufferline" then
				-- Set winhighlight to override all backgrounds
				vim.wo[win].winhighlight = "Normal:TransparentBG,NormalNC:TransparentBG"
			end
		end
	end,
})

-- Create a completely transparent highlight group
vim.cmd([[
  highlight TransparentBG guibg=NONE ctermbg=NONE
]])

-- Also try to find and modify the statusline directly
vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
	callback = function()
		-- Force transparency on common UI elements that might be used by bufferline
		vim.cmd([[
      highlight StatusLine guibg=NONE ctermbg=NONE
      highlight StatusLineNC guibg=NONE ctermbg=NONE
      highlight TabLine guibg=NONE ctermbg=NONE
      highlight TabLineFill guibg=NONE ctermbg=NONE
      highlight TabLineSel guibg=NONE ctermbg=NONE
    ]])
	end,
})
