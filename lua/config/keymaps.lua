local keymap = vim.keymap
local create_and_upload_diff = require("util.diff_upload").create_and_upload_diff
local copy_diagnostics_to_clipboard = require("util.copy_diag").copy_diagnostics_to_clipboard

-- dir navigation
keymap.set("n", "<C-h>", "<C-w>h")
keymap.set("n", "<C-l>", "<C-w>l")
keymap.set("n", "<C-j>", "<C-w>j")
keymap.set("n", "<C-k>", "<C-w>k")
keymap.set("n", "<leader>n", ":nohlsearch<CR>", { silent = true })

-- buffers navigation
keymap.set("n", "<S-l>", ":bn<CR>", { silent = true })
keymap.set("n", "<S-h>", ":bp<CR>", { silent = true })

-- misc
keymap.set("n", "<leader>y", ":%y+<CR>", { desc="Copy whole file", silent = true })
keymap.set('n', '<leader>Y', copy_diagnostics_to_clipboard, { noremap = true, desc = "Copy diagnostics" })

keymap.set('n', '<leader>gb', create_and_upload_diff, { noremap = true, desc = "Upload diff to SSH" })
keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file", silent = true })

keymap.set("n", "<leader>p", "ggVGp<CR>", { desc = "Paste in whole file", silent = true })
-- In init.lua

-- go to only errors
keymap.set("n", "[D", function()
	vim.diagnostic.goto_prev({
		severity = vim.diagnostic.severity.ERROR,
	})
end, { silent = true })

keymap.set("n", "]D", function()
	vim.diagnostic.goto_next({
		severity = vim.diagnostic.severity.ERROR,
	})
end, { silent = true })

-- go to warnings
keymap.set("n", "]d", function()
	vim.diagnostic.goto_next()
end, { silent = true })

keymap.set("n", "[d", function()
	vim.diagnostic.goto_prev()
end, { silent = true })

keymap.set("n", "<leader>h", ":normal! 0<CR>", { desc="Scroll to left", noremap = true, silent = true })

keymap.set("i", "kj", "<Esc>")
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Workspace operations
vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code actions" })
-- vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)      -- Format document
