require("config.lazy")
-- require("plugins.highlightedyank")

vim.cmd("colorscheme tokyodark")
vim.g.highlightedyank_highlight_duration = 150
-- Replace the existing <leader>n mapping with:

vim.keymap.set("n", "<leader>n", ":nohlsearch<CR>", { desc = "Clear Search Highlight", silent = true })

-- Add to your init.lua or lsp config
-- vim.diagnostic.config({
-- 	signs = true,
-- 	virtual_text = true,
-- 	float = { border = "rounded" },
-- 	severity_sort = true,
-- 	update_in_insert = false,
-- 	code_action = {
-- 		sign = false, -- Set to false to disable the lightbulb
-- 	},
-- })
