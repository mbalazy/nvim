local diagnostic_signs = require("util.icons").diagnostic_signs

local config = function()
	require("neoconf").setup({})
	local capabilities = require("blink.cmp").get_lsp_capabilities()

	-- Global LSP config (applies to all servers)
	vim.lsp.config("*", {
		capabilities = capabilities,
	})

	-- ESLint setup for modern projects with eslint.config.js (flat config)
	vim.lsp.config("astro", {})

	vim.lsp.config("eslint", {
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "astro" },
		settings = {
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

	vim.lsp.config("lua_ls", {
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

	vim.lsp.config("pyright", {
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

	vim.lsp.config("jsonls", {
		filetypes = { "json", "jsonc" },
	})

	vim.lsp.config("bashls", {
		filetypes = { "sh", "aliasrc" },
	})

	vim.lsp.config("cssls", {
		filetypes = { "css", "scss", "less" },
	})

	vim.lsp.config("emmet_ls", {
		filetypes = {
			"css",
			"sass",
			"scss",
			"less",
			"svelte",
			"html",
		},
	})

	vim.lsp.config("dockerls", {})

	vim.lsp.config("clangd", {
		cmd = {
			"clangd",
			"--offset-encoding=utf-16",
		},
	})

	-- Wyłącz omnisharp (używamy csharp_ls)
	vim.lsp.config("omnisharp", {
		enabled = false,
	})

	-- C# / .NET (csharp_ls - lżejszy niż omnisharp)
	vim.lsp.config("csharp_ls", {
		cmd = { vim.fn.expand("~/.dotnet/tools/csharp-ls") },
		cmd_env = {
			DOTNET_ROOT = "/opt/homebrew/opt/dotnet@8/libexec",
		},
		filetypes = { "cs" },
		root_markers = { "*.sln", "*.csproj", ".git" },
	})

	-- EFM server for formatting tools
	local luacheck = require("efmls-configs.linters.luacheck")
	local stylua = require("efmls-configs.formatters.stylua")
	local flake8 = require("efmls-configs.linters.flake8")
	local black = require("efmls-configs.formatters.black")
	local prettier_d = require("efmls-configs.formatters.prettier_d")
	local biome = require("efmls-configs.formatters.biome")
	local fixjson = require("efmls-configs.formatters.fixjson")
	local shellcheck = require("efmls-configs.linters.shellcheck")
	local shfmt = require("efmls-configs.formatters.shfmt")
	local hadolint = require("efmls-configs.linters.hadolint")
	local cpplint = require("efmls-configs.linters.cpplint")
	local clangformat = require("efmls-configs.formatters.clang_format")

	vim.lsp.config("efm", {
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
				javascript = { biome },
				typescript = { biome },
				javascriptreact = { biome },
				typescriptreact = { biome },
				vue = { prettier_d },
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

	-- Enable all configured LSP servers
	vim.lsp.enable({
		"astro",
		"eslint",
		"lua_ls",
		"pyright",
		"jsonls",
		"bashls",
		"cssls",
		"emmet_ls",
		"dockerls",
		"clangd",
		"efm",
		"csharp_ls",
	})

	-- Diagnostic configuration (nowy sposób dla nvim 0.11+)
	vim.diagnostic.config({
		virtual_text = { current_line = false },
		severity_sort = true,
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
				[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
				[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
				[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
			},
		},
	})
end

return {
	"neovim/nvim-lspconfig",
	config = config,
	event = "VeryLazy",
	dependencies = {
		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			opts = {
				disable_in_macro = true,
				check_ts = true,
				ts_config = {
					lua = { "string" },
					javascript = { "template_string" },
					java = false,
				},
			},
		},
		"williamboman/mason.nvim",
		"creativenull/efmls-configs-nvim",
		"saghen/blink.cmp",
	},
}
