return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		require("which-key").setup()
		-- Register your keymaps here
		local wk = require("which-key")
		local session = require("config.sessions")
		wk.add({
			{ "<leader>q", "<cmd>bdelete<cr>", desc = "Close buffer" },
			{ "<leader>L", "<cmd>Lazy<cr>", desc = "Lazy.nvim" },

			{ "<leader>b", group = "Search" },
			{ "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "Close all buffers to the left" },
			{ "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "Close all buffers to the right" },
			{ "<leader>s", group = "Search" },
			{ "<leader>u", group = "Toggle" },
			{ "<leader>S", group = "Session" },
			{ "<leader>Ss", session.save_git_session, desc = "Save Git session" },
			{ "<leader>Sl", session.load_git_session, desc = "Load Git session" },

			{ "<leader>m", "<cmd>Mason<cr>", desc = "Mason" },

			{ "<leader>l", group = "LSP" },
			{ "<leader>lo", "<cmd>TSToolsOrganizeImports<cr>", desc = "Organize Imports" },
			{ "<leader>ls", "<cmd>TSToolsSortImports<cr>", desc = "Sort Imports" },
			{ "<leader>li", "<cmd>TSToolsAddMissingImports<cr>", desc = "Organize Imports" },
			{ "<leader>lF", "<cmd>TSToolsFixAll<cr>", desc = "Fix All" },
			{ "<leader>ll", "<cmd>TSToolsFileReferences<cr>", desc = "File Reference" },
			{ "<leader>lu", "<cmd>TSToolsRemoveUnused<cr>", desc = "Organize Imports" },
			{
				"<leader>lf",
				function()
					vim.lsp.buf.format()
				end,
				desc = "Format",
			},
			{ "<leader>lI", "<cmd>LspInfo<CR>", desc = "LSP Info" },

      { "<leader>g", group = "Git" },
			-- { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "NvimTree Toggle" },
		})
	end,
}
