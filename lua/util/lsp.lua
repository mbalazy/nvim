local M = {}

-- M.on_attach = function(client, bufnr)
-- 	local opts = { noremap = true, silent = true, buffer = bufnr }
--
-- 	vim.keymap.set("n", "<leader>fd", "<cmd>Lspsaga finder<CR>", opts) -- go to definition
-- 	vim.keymap.set("n", "<leader>gd", "<cmd>Lspsaga peek_definition<CR>", opts) -- peak definition
-- 	vim.keymap.set("n", "<leader>gD", "<cmd>Lspsaga goto_definition<CR>", opts) -- go to definition
--
-- 	vim.keymap.set("n", "<leader>gS", "<cmd>vsplit | Lspsaga goto_definition<CR>", opts) -- go to definition
-- 	vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- see available code actions
-- 	vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts) -- smart rename
-- 	vim.keymap.set("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts) -- show diagnostics for line
-- 	vim.keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts) -- show diagnostics for cursor
--
-- 	vim.keymap.set("n", "<leader>pd", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- jump to prev diagnostic in buffer
-- 	vim.keymap.set("n", "<leader>nd", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- jump to next diagnostic in buffer
-- 	vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts) -- show documentation for what is under cursor
--
-- 	if client.name == "pyright" then
-- 		vim.keymap.set("n", "<leader>oi", "<cmd>PyrightOrganizeImports<CR>", opts) -- organise imports
-- 		vim.keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", opts) -- toggle breakpoint
-- 		vim.keymap.set("n", "<leader>dr", "<cmd>DapContinue<CR>", opts) -- continue/invoke debugger
-- 		vim.keymap.set("n", "<leader>dt", "<cmd>lua require('dap-python').test_method()<CR>", opts) -- run tests
-- 	end
--
-- 	if client.name == "ts_ls" then
-- 		vim.keymap.set("n", "<leader>oi", "<cmd>TypeScriptOrganizeImports<CR>", opts) -- organise imports
-- 	end
-- end

M.typescript_organise_imports = {
	description = "Organise Imports",
	function()
		local params = {
			command = "_typescript.organizeImports",
			arguments = { vim.fn.expand("%:p") },
		}
		-- reorganise imports
		vim.lsp.buf.execute_command(params)
	end,
}

return M
