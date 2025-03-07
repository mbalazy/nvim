-- ~/.config/nvim/lua/plugins/rainbow-delimiters.lua
return {
	"HiPhish/rainbow-delimiters.nvim",
	event = "BufReadPost",
	config = function()
		vim.cmd([[
            highlight RainbowDelimiterRed guifg=#E06C75
            highlight RainbowDelimiterYellow guifg=#E5C07B
            highlight RainbowDelimiterBlue guifg=#61AFEF
            highlight RainbowDelimiterOrange guifg=#D19A66
            highlight RainbowDelimiterGreen guifg=#98C379
            highlight RainbowDelimiterViolet guifg=#C678DD
            highlight RainbowDelimiterCyan guifg=#56B6C2
        ]])

		-- The plugin works with the default config when loaded
	end,
}
