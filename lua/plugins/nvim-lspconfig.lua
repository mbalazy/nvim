local diagnostic_signs = require("util.icons").diagnostic_signs

local config = function()
	require("neoconf").setup({})
	local lspconfig = require("lspconfig")
	local capabilities = require("blink.cmp").get_lsp_capabilities()

	-- ESLint setup for modern projects with eslint.config.js (flat config)
	lspconfig.eslint.setup({
		capabilities = capabilities,
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
		settings = {
			-- Support for flat config
			experimental = {
				useFlatConfig = true,
			},
			codeAction = {
				disableRuleComment = {
					enable = true,
					location = "separateLine",
				},
				showDocumentation = {
					enable = true,
				},
			},
			format = true,
			packageManager = "npm",
			validate = "on",
			workingDirectory = {
				mode = "location",
			},
		},
	})

	-- Other language servers (unchanged)
	lspconfig.lua_ls.setup({
		capabilities = capabilities,
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = {
						vim.fn.expand("$VIMRUNTIME/lua"),
						vim.fn.expand("$HOME") .. "/nvim/lua",
					},
				},
			},
		},
	})

	-- Remaining language server configurations
	lspconfig.pyright.setup({
		capabilities = capabilities,
		settings = {
			pyright = {
				disableOrganizeImports = false,
				analysis = {
					useLibraryCodeForTypes = true,
					autoSearchPaths = true,
					diagnosticMode = "workspace",
					autoImportCompletions = true,
				},
			},
		},
	})

	lspconfig.jsonls.setup({
		capabilities = capabilities,
		filetypes = { "json", "jsonc" },
	})

	lspconfig.bashls.setup({
		capabilities = capabilities,
		filetypes = { "sh", "aliasrc" },
	})

	lspconfig.cssls.setup({
		capabilities = capabilities,
		filetypes = { "css", "scss", "less" },
	})

	lspconfig.emmet_ls.setup({
		capabilities = capabilities,
		filetypes = {
			"css",
			"sass",
			"scss",
			"less",
			"svelte",
			"html",
		},
	})

	lspconfig.dockerls.setup({
		capabilities = capabilities,
	})

	lspconfig.clangd.setup({
		capabilities = capabilities,
		cmd = {
			"clangd",
			"--offset-encoding=utf-16",
		},
	})

	-- Diagnostic configuration
	for type, icon in pairs(diagnostic_signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
	end

	vim.diagnostic.config({
		virtual_text = { current_line = false },
		severity_sort = true,
	})

	local luacheck = require("efmls-configs.linters.luacheck")
	local stylua = require("efmls-configs.formatters.stylua")
	local flake8 = require("efmls-configs.linters.flake8")
	local black = require("efmls-configs.formatters.black")
	local prettier_d = require("efmls-configs.formatters.prettier_d")

local biome = require('efmls-configs.formatters.biome')
	local fixjson = require("efmls-configs.formatters.fixjson")
	local shellcheck = require("efmls-configs.linters.shellcheck")
	local shfmt = require("efmls-configs.formatters.shfmt")
	local hadolint = require("efmls-configs.linters.hadolint")
	local cpplint = require("efmls-configs.linters.cpplint")
	local clangformat = require("efmls-configs.formatters.clang_format")

	-- Configure efm server for formatting tools
	lspconfig.efm.setup({
		filetypes = {
			"lua",
			"python",
			"json",
			"jsonc",
			"sh",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
			"markdown",
			"docker",
			"html",
			"css",
			"c",
			"cpp",
		},
		init_options = {
			documentFormatting = true,
			documentRangeFormatting = true,
		},
		settings = {
			languages = {
				-- Formatting-only configs for JS/TS - linting handled by eslint-lsp
				javascript = { biome },
				typescript = { biome },
				javascriptreact = { biome },
				typescriptreact = { biome },
				vue = { prettier_d },

				-- Other languages with both linting and formatting
				lua = { luacheck, stylua },
				python = { flake8, black },
				json = { fixjson },
				jsonc = { fixjson },
				sh = { shellcheck, shfmt },
				markdown = { prettier_d },
				docker = { hadolint, prettier_d },
				html = { prettier_d },
				css = { prettier_d },
				c = { clangformat, cpplint },
				cpp = { clangformat, cpplint },
			},
		},
	})
end

return {
	"neovim/nvim-lspconfig",
	config = config,
	event = "VeryLazy",
	dependencies = {
		"windwp/nvim-autopairs",
		"williamboman/mason.nvim",
		"creativenull/efmls-configs-nvim",
		"saghen/blink.cmp",
	},
}
