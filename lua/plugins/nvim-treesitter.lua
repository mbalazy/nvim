return {
	"nvim-treesitter/nvim-treesitter",
	event = "VeryLazy",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		require("nvim-treesitter.configs").setup({
			build = ":TSUpdate",
			indent = {
				enable = true,
			},
			event = {
				"BufReadPre",
				"BufNewFile",
			},
			ensure_installed = {
				"vim",
				"regex",
				"rust",
				"markdown",
				"json",
				"javascript",
				"typescript",
				"yaml",
				"html",
				"css",
				"markdown",
				"bash",
				"lua",
				"dockerfile",
				"solidity",
				"gitignore",
				"python",
				"vue",
				"svelte",
				"toml",
			},
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = true,
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-s>",
					node_incremental = "<C-s>",
					scope_incremental = false,
					node_decremental = "<BS>",
				},
			},
		})

		-- The new preferred way to set up autotag
		require("nvim-ts-autotag").setup({
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = false,
			},
			-- Disable for specific filetypes if needed
			per_filetype = {
				-- For example, disable in markdown
				["markdown"] = {
					enable_close = false,
					enable_rename = false,
				},
			},
		})
	end,
}
