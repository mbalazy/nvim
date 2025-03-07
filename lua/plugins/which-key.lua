return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		require("which-key").setup({})
		-- Register your keymaps here
		local wk = require("which-key")
		wk.add({
			{ "<leader>f", "<cmd>FzfLua files<cr>", desc = "Find Files" },
			{ "<leader>q", "<cmd>bdelete<cr>", desc = "Find Files" },

			{ "<leader>s", group = "Search" }, -- group
			{ "<leader>sf", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
			{ "<leader>sb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },

			{ "<leader>b", group = "Search" }, -- group
			{ "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "Close all buffers to the left" }, -- group

			{ "<leader>m", "<cmd>Mason<cr>", desc = "Mason" },
			{
				"<leader>lf",
				function()
					vim.lsp.buf.format({ name = "efm" })
				end,
				desc = "Format",
			},

			{ "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "NvimTree Toggle" },
		})
	end,
}
