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
		local ts = require("util.typescript")
		wk.add({
			{ "<leader>q", "<cmd>bdelete<cr>", desc = "Close buffer" },
			{ "<leader>L", "<cmd>Lazy<cr>", desc = "Lazy.nvim" },

			{ "<leader>b", group = "Buffer" },
			{ "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<cr>", desc = "Close other buffers" },

			{ "<leader>s", group = "Search" },
			{ "<leader>sc", "<cmd>BrowseCommitFiles<cr>", desc = "Browse files in commit" },

			{ "<leader>u", group = "Toggle" },

			{ "<leader>S", group = "Session" },
			{ "<leader>Ss", session.save_session, desc = "Save Git session" },
			{ "<leader>Sl", session.load_session, desc = "Load Git session" },

			{ "<leader>m", "<cmd>Mason<cr>", desc = "Mason" },

			{ "<leader>l", group = "LSP" },
			{ "<leader>lo", ts.organize_imports, desc = "Organize Imports" },
			{ "<leader>ls", ts.sort_imports, desc = "Sort Imports" },
			{ "<leader>lS", "<cmd>LspStart<cr>", desc = "Start LSP" },
			{ "<leader>li", ts.add_missing_imports, desc = "Add Missing Imports" },
			{ "<leader>lF", ts.fix_all, desc = "Fix All" },
			{ "<leader>ll", ts.file_references, desc = "File References" },
			{ "<leader>lu", ts.remove_unused, desc = "Remove unused" },
			{ "<leader>ly", "<cmd>CopyDiag<cr>", desc = "Copy diagnostic" },
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
