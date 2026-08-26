local keymap = vim.keymap

-- dir navigation
keymap.set("n", "<C-h>", "<C-w>h")
keymap.set("n", "<C-l>", "<C-w>l")
keymap.set("n", "<C-j>", "<C-w>j")
keymap.set("n", "<C-k>", "<C-w>k")
keymap.set("n", "<leader>n", ":nohlsearch<CR>", { silent = true })

-- buffers navigation
keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>", { silent = true })
keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>", { silent = true })

-- misc
keymap.set("n", "<leader>y", ":%y+<CR>", { desc = "Copy whole file", silent = true })

keymap.set("n", "<leader>gb", function() require("util.diff_upload").create_and_upload_diff() end, { noremap = true, desc = "Upload diff to SSH" })
keymap.set("n", "<leader>gO", "<cmd>GitStashNamed<cr>", { noremap = true, desc = "Create Stash" })
keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file", silent = true })

keymap.set("n", "<leader>p", "ggVGp<CR>", { desc = "Paste in whole file", silent = true })
keymap.set("n", "<leader>x", "<cmd>tabclose<CR>", { desc = "Close tab", silent = true })

-- Copy filename utilities
keymap.set("n", "<leader>Yf", "<cmd>CopyFilename<CR>", { desc = "Copy filename", silent = true })
keymap.set("n", "<leader>Yl", function()
	vim.fn.setreg("+", vim.fn.line("."))
end, { desc = "Copy line number", silent = true })
keymap.set("n", "<leader>Yp", "<cmd>CopyFilePath<CR>", { desc = "Copy file path", silent = true })
keymap.set("n", "<leader>YP", "<cmd>CopyFileAbsolutePath<CR>", { desc = "Copy absolute path", silent = true })

keymap.set("n", "≤", "<Cmd>BufferLineMovePrev<CR>", {})
keymap.set("n", "≥", "<Cmd>BufferLineMoveNext<CR>", {})

keymap.set("n", "<A-h>", "<Cmd>BufferLineCyclePrev<CR>", {})
keymap.set("n", "<A-l>", "<Cmd>BufferLineCycleNext<CR>", {})

-- Diagnostics navigation (vim.diagnostic.jump - goto_next/goto_prev are deprecated)
keymap.set("n", "[D", function()
	vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR })
end, { silent = true, desc = "Previous error" })

keymap.set("n", "]D", function()
	vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR })
end, { silent = true, desc = "Next error" })

keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { silent = true, desc = "Next diagnostic" })

keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { silent = true, desc = "Previous diagnostic" })

-- Treesitter incremental selection (built into Neovim 0.12; replaces the
-- nvim-treesitter `incremental_selection` module from the master branch).
-- <C-s>: select node at cursor / grow to parent, <BS>: shrink to child.
keymap.set({ "n", "x" }, "<C-s>", function()
	vim.treesitter.select("parent")
end, { silent = true, desc = "Select treesitter node / parent" })
keymap.set("x", "<BS>", function()
	vim.treesitter.select("child")
end, { silent = true, desc = "Shrink selection to child node" })

keymap.set("n", "<leader>h", ":normal! 0<CR>", { desc = "Scroll to left", noremap = true, silent = true })

-- Comment toggle (built-in `gc` operator, replaces Comment.nvim).
-- Normal mode keeps the cursor where it was (Comment.nvim `sticky` behaviour).
keymap.set("n", "<leader>/", function()
	local pos = vim.api.nvim_win_get_cursor(0)
	vim.cmd.normal({ vim.v.count1 .. "gcc", bang = false })
	pcall(vim.api.nvim_win_set_cursor, 0, pos)
end, { desc = "Toggle comment line" })
keymap.set("x", "<leader>/", "gc", { remap = true, desc = "Toggle comment" })

keymap.set("i", "kj", "<Esc>")
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- LSP operations (deferred to avoid loading vim.lsp at startup)
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local buf = ev.buf
		keymap.set("n", "K", vim.lsp.buf.hover, { buffer = buf, desc = "Hover documentation" })
		keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { buffer = buf, desc = "Rename symbol" })
		keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { buffer = buf, desc = "Code actions" })
		keymap.set("n", "<leader>lf", vim.lsp.buf.format, { buffer = buf, desc = "Format file" })
	end,
})
