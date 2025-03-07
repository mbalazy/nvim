local keymap = vim.keymap

-- dir navigation
keymap.set("n", "<C-h>", "<C-w>h")
keymap.set("n", "<C-l>", "<C-w>l")
keymap.set("n", "<C-j>", "<C-w>j")
keymap.set("n", "<C-k>", "<C-w>k")
keymap.set("n", "<leader>n", ":nohlsearch<CR>", { silent = true })
keymap.set("n", "<S-l>", ":bn<CR>", { silent = true })
keymap.set("n", "<S-h>", ":bp<CR>", { silent = true })
keymap.set("n", "<leader>y", ":%y+<CR>", { silent = true })
keymap.set("n", "<leader>w", "<cmd>w<cr>", { silent = true })

keymap.set("n", "<leader>h", ":normal! 0<CR>", { noremap = true, silent = true })

keymap.set("i", "kj", "<Esc>")
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")
