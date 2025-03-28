return {
	"saghen/blink.cmp",
	-- optional: provides snippets for the snippet source
	dependencies = { "rafamadriz/friendly-snippets" },

	-- use a release tag to download pre-built binaries
	version = "1.*",

	opts = {
		-- Using 'default' preset for mappings similar to built-in completions (C-y to accept)
		keymap = {
			preset = "default",
			["<C-l>"] = { "accept", "show" },
			["<C-k>"] = { "select_prev" },
			["<C-j>"] = { "select_next" },

			["<C-u>"] = { "scroll_documentation_up" },
			["<C-d>"] = { "scroll_documentation_down" },

			["<Tab>"] = { "snippet_forward", "fallback" },
			["<S-Tab>"] = { "snippet_backward", "fallback" },

			["<C-space>"] = {
				function(cmp)
					cmp.show({ providers = { "snippets" } })
				end,
			},
		},

		appearance = {
			-- Using 'mono' for 'Nerd Font Mono' to ensure icons are aligned
			nerd_font_variant = "mono",
			-- Extend the number of visible items from default 8 to 12
		},

		-- Show documentation popup only when manually triggered
		completion = { documentation = { auto_show = true } },

		-- Default list of enabled providers
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},

		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
