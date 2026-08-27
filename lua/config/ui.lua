-- Neovim 0.12 built-in messages/cmdline UI ("ui2", experimental) - replaces noice.nvim.
-- Messages beyond 'cmdheight' collapse to a "[+x]" spill indicator: press <CR> right
-- after the command, or g< at any time, to see the full text. :messages opens the pager.
local ok, ui2 = pcall(require, "vim._core.ui2")
if ok then
	ui2.enable({
		enable = true,
		msg = {
			targets = "cmd",
			cmd = { height = 0.5 },
			dialog = { height = 0.5 },
			msg = { height = 0.5, timeout = 4000 },
			pager = { height = 1 },
		},
	})
end
