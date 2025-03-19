return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		require("which-key").setup({
			preset = "modern",
			layout = {
				width = { min = 20 }, -- min and max width of the columns
				spacing = 1, -- spacing between columns
			},
			icons = {
				mappings = false,
			},
		})
		-- Register your keymaps here
		local wk = require("which-key")
		--  todo: dont require - make session fn's global cmd's
		local session = require("config.sessions")
		wk.add({
			{ "<leader>q", "<cmd>bdelete<cr>", desc = "Close buffer" },
			{ "<leader>L", "<cmd>Lazy<cr>", desc = "Lazy.nvim" },

			{ "<leader>b", group = "BufferLine" },
			{ "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "Close all buffers to the left" },
			{ "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "Close all buffers to the right" },

			{ "<leader>s", group = "Search" },

			{ "<leader>u", group = "Toggle" },

			{ "<leader>S", group = "Session" },
			{ "<leader>Ss", session.save_session, desc = "Save Git session" },
			{ "<leader>Sl", session.load_session, desc = "Load Git session" },

			{ "<leader>m", "<cmd>Mason<cr>", desc = "Mason" },

			{ "<leader>l", group = "LSP" },
			{ "<leader>lo", "<cmd>TSToolsOrganizeImports<cr>", desc = "Organize Imports" },
			{ "<leader>ls", "<cmd>TSToolsSortImports<cr>", desc = "Sort Imports" },
			{ "<leader>li", "<cmd>TSToolsAddMissingImports<cr>", desc = "Add Missing Imports" },
			{ "<leader>lF", "<cmd>TSToolsFixAll<cr>", desc = "Fix All" },
			{ "<leader>ll", "<cmd>TSToolsFileReferences<cr>", desc = "File Reference" },
			{ "<leader>lu", "<cmd>TSToolsRemoveUnused<cr>", desc = "Remove unused" },
			{
				"<leader>lf",
				function()
					vim.lsp.buf.format()
				end,
				desc = "Format",
			},
			{ "<leader>lI", "<cmd>LspInfo<CR>", desc = "LSP Info" },

			{ "<leader>g", group = "Git" },
			{ "<leader>d", group = "DiffView" },
			{ "<leader>da", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview (merge conflicts)" },
			{ "<leader>de", "<cmd>DiffviewFileHistory %<cr>", desc = "Browse commits on this file" },
			{ "<leader>dE", "<cmd>DiffviewFileHistory<cr>", desc = "Browse commits on this branch" },
			{ "<leader>db", "<cmd>CompareBranch<cr>", desc = "Compare with branch" },
		})
	end,
}
