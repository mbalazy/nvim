local config = function()
	require("gitsigns").setup({
		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")

			-- Navigation between hunks
			vim.keymap.set("n", "]g", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gitsigns.nav_hunk("next")
				end
			end, { buffer = bufnr, desc = "Next git hunk" })

			vim.keymap.set("n", "[g", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
			end, { buffer = bufnr, desc = "Previous git hunk" })

			-- Hunk Actions (Normal Mode)
			vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk, { buffer = bufnr, desc = "Stage current hunk" })
			vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { buffer = bufnr, desc = "Reset current hunk" })

			-- Hunk Actions (Visual Mode)
			-- vim.keymap.set("v", "<leader>gs", function()
			-- 	gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			-- end, { buffer = bufnr, desc = "Stage selected hunk" })

			vim.keymap.set("v", "<leader>gr", function()
				gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { buffer = bufnr, desc = "Reset selected hunk" })

			-- Buffer-wide Actions
			vim.keymap.set("n", "<leader>gS", gitsigns.stage_buffer, { buffer = bufnr, desc = "Stage entire buffer" })
			vim.keymap.set("n", "<leader>gR", gitsigns.reset_buffer, { buffer = bufnr, desc = "Reset entire buffer" })

			-- Hunk Preview
			vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
			vim.keymap.set(
				"n",
				"<leader>gi",
				gitsigns.preview_hunk_inline,
				{ buffer = bufnr, desc = "Preview hunk inline" }
			)

			-- Blame and Diff
			vim.keymap.set("n", "<leader>gl", function()
				gitsigns.blame_line()
			end, { buffer = bufnr, desc = "Show blame" })

			vim.keymap.set("n", "<leader>gL", function()
				gitsigns.blame_line({ full = true })
			end, { buffer = bufnr, desc = "Show full line blame" })

			vim.keymap.set("n", "<leader>gB", function()
				gitsigns.blame()
			end, { buffer = bufnr, desc = "Show blame on file" })

			vim.keymap.set(
				"n",
				"<leader>ga",
				gitsigns.diffthis,
				{ buffer = bufnr, desc = "Show diff for current file" }
			)

			vim.keymap.set("n", "<leader>gA", function()
				gitsigns.diffthis("~")
			end, { buffer = bufnr, desc = "Show diff against previous commit" })

			-- Quickfix List
			vim.keymap.set("n", "<leader>gQ", function()
				gitsigns.setqflist("all")
			end, { buffer = bufnr, desc = "Add all hunks to quickfix list" })

			vim.keymap.set(
				"n",
				"<leader>gq",
				gitsigns.setqflist,
				{ buffer = bufnr, desc = "Add current hunks to quickfix list" }
			)

			-- Toggles
			vim.keymap.set(
				"n",
				"<leader>gtb",
				gitsigns.toggle_current_line_blame,
				{ buffer = bufnr, desc = "Toggle line blame" }
			)
			vim.keymap.set("n", "<leader>gtw", gitsigns.toggle_word_diff, { buffer = bufnr, desc = "Toggle word diff" })

			-- Text Object
			vim.keymap.set({ "o", "x" }, "ih", gitsigns.select_hunk, { buffer = bufnr, desc = "Select git hunk" })
		end,
		signs = {
			add = { text = "┃" },
			change = { text = "┃" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		signs_staged = {
			add = { text = "┃" },
			change = { text = "┃" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		signs_staged_enable = true,
		signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
		numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
		linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
		word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
		watch_gitdir = {
			follow_files = true,
		},
		auto_attach = true,
		attach_to_untracked = false,
		current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
			delay = 1000,
			ignore_whitespace = false,
			virt_text_priority = 100,
			use_focus = true,
		},
		current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
		sign_priority = 6,
		update_debounce = 100,
		status_formatter = nil, -- Use default
		max_file_length = 40000, -- Disable if file is longer than this (in lines)
		preview_config = {
			-- Options passed to nvim_open_win
			border = "single",
			style = "minimal",
			relative = "cursor",
			row = 0,
			col = 1,
		},
	})
end

return {
	"lewis6991/gitsigns.nvim",
	lazy = false,
	config = config,
}
