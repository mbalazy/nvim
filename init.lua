require("config.lazy")
require("config.sessions")
-- require("plugins.highlightedyank")

vim.cmd("colorscheme tokyodark")
vim.g.highlightedyank_highlight_duration = 150
-- Replace the existing <leader>n mapping with:

vim.keymap.set("n", "<leader>n", ":nohlsearch<CR>", { desc = "Clear Search Highlight", silent = true })
vim.keymap.set("n", "<leader>p", "ggVGp<CR>", { desc = "Paste in whole file", silent = true })

require("nvim-autopairs").setup({
	disable_in_macro = true,

	check_ts = true,
	ts_config = {
		lua = { "string" },
		javascript = { "template_string" },
		java = false,
	},
})
