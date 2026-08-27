-- Disabled 2026-08-27: not in use right now. Re-enable together with the
-- built-in ACP provider `claude-code` (see pm task nvim-2 / PLUGIN_ALTERNATIVES.md 5.1).
return {
	"yetone/avante.nvim",
	enabled = false,
	event = "VeryLazy",
	version = false, -- Never set this value to "*"! Never!
	opts = {
		provider = "claude",
		-- vim.ui.input / pickers via snacks.nvim (dressing.nvim is archived and
		-- was overriding Snacks' vim.ui.input / vim.ui.select handlers).
		input = {
			provider = "snacks",
		},
		selector = {
			provider = "snacks",
		},
		windows = {
			--  "right" | "left" | "top" | "bottom"
			position = "right", -- the position of the sidebar
			wrap = true, -- similar to vim.o.wrap
			width = 40, -- default % based on available width
			sidebar_header = {
				enabled = false, -- true, false to enable/disable the header
			},
			input = {
				prefix = "> ",
				height = 8, -- Height of the input window in vertical layout
			},
			edit = {
				border = "rounded",
				start_insert = true, -- Start insert mode when opening the edit window
			},
		},
		-- openai = {
		-- 	endpoint = "https://api.openai.com/v1",
		-- 	model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
		-- 	timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
		-- 	temperature = 0,
		-- 	max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
		-- 	--reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
		-- },
	},
	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	build = "make",
	-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		"folke/snacks.nvim", -- input + selector provider
		"saghen/blink.cmp", -- autocompletion for avante commands and mentions
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
		-- "zbirenbaum/copilot.lua", -- for providers='copilot'
		{
			-- support for image pasting
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				-- recommended settings
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
					-- required for Windows users
					use_absolute_path = true,
				},
			},
		},
	},
}
