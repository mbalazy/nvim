-- Linting via nvim-lint (replaces the efm-langserver linters).
-- Tools from Mason: luacheck flake8 shellcheck hadolint cpplint.
return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPost", "BufNewFile", "BufWritePost" },
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			lua = { "luacheck" },
			python = { "flake8" },
			sh = { "shellcheck" },
			dockerfile = { "hadolint" },
			c = { "cpplint" },
			cpp = { "cpplint" },
		}

		local function try_lint(buf)
			if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modifiable then
				vim.api.nvim_buf_call(buf, function()
					lint.try_lint(nil, { ignore_errors = true })
				end)
			end
		end

		local group = vim.api.nvim_create_augroup("user_lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
			group = group,
			callback = function(ev)
				try_lint(ev.buf)
			end,
		})

		-- The plugin is lazy-loaded on the very event above, so the buffer that
		-- triggered the load has already passed BufReadPost: lint it now.
		vim.schedule(function()
			try_lint(vim.api.nvim_get_current_buf())
		end)
	end,
}
