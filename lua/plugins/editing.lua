return {
	-- Text objects: a/i for brackets, quotes, arguments, plus treesitter-based
	-- af/if (function) and ac/ic (class). Queries come from nvim-treesitter-textobjects.
	{
		"nvim-mini/mini.ai",
		event = "VeryLazy",
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
		},
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 300,
				custom_textobjects = {
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
				},
			}
		end,
	},

	-- Sticky function/class header while scrolling
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "VeryLazy",
		opts = {
			max_lines = 4,
			multiline_threshold = 2,
		},
		keys = {
			{
				"<leader>ut",
				function()
					require("treesitter-context").toggle()
				end,
				desc = "Toggle Treesitter Context",
			},
		},
	},

	-- Label-based jumps (s), treesitter selection (S), remote operator-pending (r)
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
			{ "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
			{ "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
			{ "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
		},
	},

	-- Project-wide search and replace (ripgrep) in a buffer
	{
		"MagicDuck/grug-far.nvim",
		cmd = "GrugFar",
		opts = { headerMaxWidth = 80 },
		keys = {
			{
				"<leader>sg",
				function()
					local grug = require("grug-far")
					local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
					grug.open({
						transient = true,
						prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
					})
				end,
				mode = { "n", "x" },
				desc = "Search and Replace (grug-far)",
			},
		},
	},
}
