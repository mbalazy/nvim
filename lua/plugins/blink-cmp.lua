return {
	"saghen/blink.cmp",
	-- optional: provides snippets for the snippet source
	dependencies = { "rafamadriz/friendly-snippets" },

	-- use a release tag to download pre-built binaries
	version = "1.*",

	-- workaround: blink-cmp.lua:2 indexes vim.lsp.config['*'] which is nil
	-- until a global LSP config is set. Fixed upstream (f85eb62) but not released yet.
	init = function()
		if vim.fn.has("nvim-0.11") == 1 and vim.lsp.config and not vim.lsp.config["*"] then
			vim.lsp.config("*", {})
		end
	end,

	opts = {
		-- Using 'default' preset for mappings similar to built-in completions (C-y to accept)
		keymap = {
			preset = "default",
			["<C-l>"] = { "accept", "show" },
			["<C-k>"] = { "select_prev" },
			["<C-j>"] = { "select_next" },

			["<C-u>"] = { "scroll_documentation_up" },
			["<C-d>"] = { "scroll_documentation_down" },
			["<C-f>"] = {
				function(cmp)
					cmp.show_documentation({ focus = true })
				end,
			},
      

			["<Tab>"] = { "snippet_forward", "fallback" },
			["<S-Tab>"] = { "snippet_backward", "fallback" },

			-- <C-s> stays free: Neovim 0.12 maps it to vim.lsp.buf.signature_help()
			["<C-x>"] = {
				function(cmp)
					cmp.show({ providers = { "snippets" } })
				end,
			},
		},

		appearance = {
			nerd_font_variant = "mono",
		},

		completion = {
			documentation = { auto_show = true },
			menu = {
				auto_show = true,
				max_height = 15,
			},
		},

		-- Default list of enabled providers
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},

		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
