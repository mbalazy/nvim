local mason = {
	"williamboman/mason.nvim",
	cmd = "Mason",
	event = "BufReadPre",
	opts = {
		ui = {
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
		},
	},
}

local mason_lspconfig = {
	"williamboman/mason-lspconfig.nvim",
	opts = {
		ensure_installed = {
			"solidity_ls",
			"efm",
			"bashls",
			"tailwindcss",
			"cssls",
			"pyright",
			"lua_ls",
			"emmet_ls",
			"jsonls",
			"clangd",
			"dockerls",
			"astro",
			-- "omnisharp", -- wyłączone - używamy csharp-ls
		},
		automatic_installation = false,
		automatic_enable = false,
	},
	event = "BufReadPre",
	dependencies = "williamboman/mason.nvim",
}

return {
	mason,
	mason_lspconfig,
}
