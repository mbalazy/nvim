local diagnostic_signs = require("util.icons").diagnostic_signs
local typescript_organise_imports = require("util.lsp").typescript_organise_imports

local config = function()
	require("neoconf").setup({})
	local cmp_nvim_lsp = require("cmp_nvim_lsp")
	local lspconfig = require("lspconfig")
	local capabilities = cmp_nvim_lsp.default_capabilities()

	-- lua
	lspconfig.lua_ls.setup({
		capabilities = capabilities,
		settings = { -- custom settings for lua
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

	-- python
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

	-- json
	-- lspconfig.jsonls.setup({
	-- 	capabilities = capabilities,
	-- 	on_attach = on_attach,
	-- 	filetypes = { "json", "jsonc" },
	-- })

	-- require'lspconfig'.ts_ls.setup{
	--   init_options = {
	--     plugins = {
	--       {
	--         name = "@vue/typescript-plugin",
	--         location = "/usr/local/lib/node_modules/@vue/typescript-plugin",
	--         languages = {"javascript", "typescript", "vue"},
	--       },
	--     },
	--   },
	--   filetypes = {
	--     "javascript",
	--     "typescript",
	--     "vue",
	--   },
	-- }
	--

	lspconfig.ts_ls.setup({
		-- on_attach = on_attach,
		capabilities = capabilities,
		init_options = {
			plugins = {
				{
					name = "@vue/typescript-plugin",
					location = "~/.local/share/nvim/mason/bin/vue-language-serve",
					languages = { "vue" },
				},
			},
		},
		filetypes = {
			"typescript",
			"javascript",
			"typescriptreact",
			"javascriptreact",
      "vue",
		},
		commands = {
			TypeScriptOrganizeImports = typescript_organise_imports,
		},
		settings = {
			typescript = {
				indentStyle = "space",
				indentSize = 2,
			},
		},
	})

  -- lspconfig.volar.setup {
  --   -- add filetypes for typescript, javascript and vue
  --   filetypes = { 'vue' },
  --   init_options = {
  --     vue = {
  --       hybridMode = false,
  --     },
  --   },
  -- }

	-- bash
	-- lspconfig.bashls.setup({
	-- 	capabilities = capabilities,
	-- 	on_attach = on_attach,
	-- 	filetypes = { "sh", "aliasrc" },
	-- })

	-- typescriptreact, javascriptreact, css, sass, scss, less, svelte, vue
	-- lspconfig.emmet_ls.setup({
	-- 	capabilities = capabilities,
	-- 	on_attach = on_attach,
	-- 	filetypes = {
	-- 		"typescriptreact",
	-- 		"javascriptreact",
	-- 		"javascript",
	-- 		"css",
	-- 		"sass",
	-- 		"scss",
	-- 		"less",
	-- 		"svelte",
	-- 		"vue",
	-- 		"html",
	-- 	},
	-- })
	--
	-- docker
	-- lspconfig.dockerls.setup({
	-- 	capabilities = capabilities,
	-- 	on_attach = on_attach,
	-- })

	-- C/C++
	-- lspconfig.clangd.setup({
	-- 	capabilities = capabilities,
	-- 	on_attach = on_attach,
	-- 	cmd = {
	-- 		"clangd",
	-- 		"--offset-encoding=utf-16",
	-- 	},
	-- })

	for type, icon in pairs(diagnostic_signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
	end

	-- local solhint = require("efmls-configs.linters.solhint")
	local luacheck = require("efmls-configs.linters.luacheck")
	local stylua = require("efmls-configs.formatters.stylua")
	local flake8 = require("efmls-configs.linters.flake8")
	local black = require("efmls-configs.formatters.black")
	local eslint_d = require("efmls-configs.linters.eslint_d")
	local prettier_d = require("efmls-configs.formatters.prettier_d")
	-- local fixjson = require("efmls-configs.formatters.fixjson")
	-- local shellcheck = require("efmls-configs.linters.shellcheck")
	-- local shfmt = require("efmls-configs.formatters.shfmt")
	-- local hadolint = require("efmls-configs.linters.hadolint")
	-- local cpplint = require("efmls-configs.linters.cpplint")
	-- local clangformat = require("efmls-configs.formatters.clang_format")

	-- configure efm server
	lspconfig.efm.setup({
		filetypes = {
			"lua",
			"python",
			-- "json",
			-- "jsonc",
			-- "sh",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
			-- "markdown",
			-- "docker",
			-- "html",
			-- "css",
			-- "c",
			-- "cpp",
		},

		init_options = {
			documentFormatting = true,
			documentRangeFormatting = true,
			hover = true,
			documentSymbol = true,
			codeAction = true,
			completion = true,
		},

		settings = {
			languages = {
				lua = { luacheck, stylua },
				python = { flake8, black },
				typescript = { eslint_d, prettier_d },
				-- json = { eslint, fixjson },
				-- jsonc = { eslint, fixjson },
				-- sh = { shellcheck, shfmt },
				javascript = { eslint_d, prettier_d },
				javascriptreact = { eslint_d, prettier_d },
				typescriptreact = { eslint_d, prettier_d },
				vue = { eslint_d, prettier_d },
				-- markdown = { prettier_d },
				-- docker = { hadolint, prettier_d },
				-- html = { prettier_d },
				-- css = { prettier_d },
				-- c = { clangformat, cpplint },
				-- cpp = { clangformat, cpplint },
			},
		},
	})
end

return {
	"neovim/nvim-lspconfig",
	config = config,
	lazy = false,
	dependencies = {
		"windwp/nvim-autopairs",
		"williamboman/mason.nvim",
		"creativenull/efmls-configs-nvim",
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-nvim-lsp",
	},
}
