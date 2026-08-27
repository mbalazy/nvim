local diagnostic_signs = require("util.icons").diagnostic_signs

local config = function()
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

	-- lua_ls: workspace libraries come from lazydev.nvim
	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
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

	vim.lsp.config("bashls", {})

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

	-- C# / .NET (csharp_ls - lżejszy niż omnisharp)
	-- Install: `dotnet tool install -g csharp-ls` (only enabled when the binary exists).
	local csharp_ls_bin = vim.fn.expand("~/.dotnet/tools/csharp-ls")
	vim.lsp.config("csharp_ls", {
		cmd = { csharp_ls_bin },
		cmd_env = {
			DOTNET_ROOT = "/opt/homebrew/opt/dotnet@8/libexec",
		},
		filetypes = { "cs" },
		root_markers = { "*.sln", "*.csproj", ".git" },
	})

	-- TypeScript / JavaScript: vtsls (replaces typescript-tools.nvim).
	-- Vue support: @vue/typescript-plugin from Mason's vue-language-server.
	local vue_plugin_path = vim.fn.stdpath("data")
		.. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
	local inlay_hints = {
		parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = false },
		parameterTypes = { enabled = true },
		variableTypes = { enabled = true },
		propertyDeclarationTypes = { enabled = true },
		functionLikeReturnTypes = { enabled = true },
		enumMemberValues = { enabled = true },
	}
	vim.lsp.config("vtsls", {
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
		settings = {
			vtsls = {
				tsserver = {
					globalPlugins = {
						{
							name = "@vue/typescript-plugin",
							location = vue_plugin_path,
							languages = { "vue" },
							configNamespace = "typescript",
						},
					},
				},
			},
			typescript = { inlayHints = inlay_hints },
			javascript = { inlayHints = inlay_hints },
		},
	})

	-- Enable all configured LSP servers
	local servers = {
		"astro",
		"eslint",
		"vtsls",
		"vue_ls",
		"tailwindcss",
		"solidity_ls",
		"lua_ls",
		"pyright",
		"jsonls",
		"bashls",
		"cssls",
		"emmet_ls",
		"dockerls",
		"clangd",
	}
	if vim.fn.executable(csharp_ls_bin) == 1 then
		table.insert(servers, "csharp_ls")
	end
	vim.lsp.enable(servers)

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
		"mason-org/mason.nvim",
		"saghen/blink.cmp",
	},
}
