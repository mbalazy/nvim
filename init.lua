-- Fix PATH for GUI Neovim (ensure homebrew binaries are available)
if vim.fn.has("mac") == 1 then
  local homebrew_bin = "/opt/homebrew/bin"
  if vim.fn.isdirectory(homebrew_bin) == 1 then
    vim.env.PATH = homebrew_bin .. ":" .. vim.env.PATH
  end
end

require("config.lazy")
require("config.sessions")
require("util.diff_upload")
require("util.create_stash")
require("util.compare_with_branch")
require("util.file_from_commit")
require("util.copy_diag")
require("util.copy_filename")
require("util.transparent_ui")

require("config.ui")

-- Highlight yanked text (replaces vim-highlightedyank)
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("user_highlight_yank", { clear = true }),
	callback = function()
		vim.hl.on_yank({ timeout = 150 })
	end,
})
