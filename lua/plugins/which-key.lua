return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		require("which-key").setup()
		-- Register your keymaps here
		local wk = require("which-key")
		wk.add({
			{ "<leader>q", "<cmd>bdelete<cr>", desc = "Find Files" },

			{ "<leader>b", group = "Search" },
			{ "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "Close all buffers to the left" },
			{ "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "Close all buffers to the right" },

			{ "<leader>m", "<cmd>Mason<cr>", desc = "Mason" },

			{ "<leader>l", group = "LSP" },
			{
				"<leader>lf",
				function()
					vim.lsp.buf.format({ name = "efm" })
				end,
				desc = "Format",
			},
			{ "<leader>li", "<cmd>LspInfo<CR>", desc = "LSP Info" },

			-- { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "NvimTree Toggle" },
		})
	end,
}
