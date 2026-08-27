-- Formatting via conform.nvim (replaces efm-langserver + efmls-configs).
-- Tools come from Mason (:MasonInstall stylua black fixjson shfmt clang-format)
-- or PATH (biome via brew, prettierd via npm -g @fsouza/prettierd).
return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>lf",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "x" },
			desc = "Format buffer / range",
		},
	},
	init = function()
		-- gq uses conform; falls back to LSP, then Vim's internal formatting
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "black" },
			json = { "fixjson" },
			jsonc = { "fixjson" },
			sh = { "shfmt" },
			javascript = { "biome" },
			javascriptreact = { "biome" },
			typescript = { "biome" },
			typescriptreact = { "biome" },
			vue = { "prettierd" },
			markdown = { "prettierd" },
			html = { "prettierd" },
			css = { "prettierd" },
			scss = { "prettierd" },
			less = { "prettierd" },
			c = { "clang_format" },
			cpp = { "clang_format" },
		},
		default_format_opts = {
			lsp_format = "fallback",
		},
		-- no format_on_save: formatting stays explicit (<leader>lf), as with efm
	},
}
