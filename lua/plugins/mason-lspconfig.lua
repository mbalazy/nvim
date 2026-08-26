local mason = {
	"mason-org/mason.nvim",
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
	"mason-org/mason-lspconfig.nvim",
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
			"vtsls",
			"vue_ls",
		},
		-- servers are enabled explicitly in nvim-lspconfig.lua
		automatic_enable = false,
	},
	event = "BufReadPre",
	dependencies = "mason-org/mason.nvim",
}

return {
	mason,
	mason_lspconfig,
}
