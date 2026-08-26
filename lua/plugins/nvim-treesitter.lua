-- nvim-treesitter `main` branch (Neovim 0.12+).
-- `main` is a rewrite: the plugin only installs parsers + queries. Highlighting,
-- folds and indentation are Neovim built-ins enabled per buffer in the
-- FileType autocmd below. Incremental selection is built into Neovim 0.12
-- (see `<C-s>` / `<BS>` in lua/config/keymaps.lua).

-- Parsers installed up front (the old `ensure_installed`). Anything else is
-- installed on demand by the FileType autocmd (the old `auto_install = true`).
local ensure_installed = {
	"astro",
	"bash",
	"c",
	"c_sharp",
	"css",
	"diff",
	"dockerfile",
	"fish",
	"gitignore",
	"html",
	"javascript",
	"json", -- also used for jsonc
	"lua",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"regex",
	"rust",
	"scss",
	"solidity",
	"svelte",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"vue",
	"yaml",
}

-- Languages that keep regex syntax highlighting only (old `highlight.disable`).
local highlight_disable = { "html" }

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false, -- the plugin does not support lazy-loading
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")
		ts.setup({}) -- parsers go to stdpath("data")/site (default)

		-- Install missing parsers (async). Filtering first keeps startup silent
		-- and avoids re-checking every parser on each launch.
		local installed = ts.get_installed("parsers")
		local missing = vim.tbl_filter(function(lang)
			return not vim.tbl_contains(installed, lang)
		end, ensure_installed)
		if #missing > 0 then
			ts.install(missing)
		end

		local group = vim.api.nvim_create_augroup("user_treesitter", { clear = true })

		local function enable(buf, lang)
			if not vim.api.nvim_buf_is_valid(buf) then
				return
			end
			if not vim.tbl_contains(highlight_disable, lang) then
				if pcall(vim.treesitter.start, buf, lang) then
					-- Keep regex syntax on top of treesitter
					-- (was `additional_vim_regex_highlighting = true` on master).
					vim.bo[buf].syntax = "ON"
				end
			end
			-- Folds: `foldexpr` is set globally in lua/config/options.lua.
			vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			callback = function(ev)
				local buf = ev.buf
				local lang = vim.treesitter.language.get_lang(ev.match)
				if not lang then
					return
				end

				if vim.treesitter.language.add(lang) then
					enable(buf, lang)
					return
				end

				-- Parser missing: install it if nvim-treesitter knows the language.
				if vim.tbl_contains(ts.get_available(), lang) then
					ts.install({ lang }):await(function(err)
						if err then
							return
						end
						vim.schedule(function()
							enable(buf, lang)
						end)
					end)
				end
			end,
		})
	end,
}
