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
require("util.clear_bufferline")

vim.cmd("colorscheme tokyodark")
vim.g.highlightedyank_highlight_duration = 150

vim.lsp.buf_request_sync_options = {
	timeout_ms = 5000,
}

require("nvim-autopairs").setup({
	disable_in_macro = true,
	check_ts = true,
	ts_config = {
		lua = { "string" },
		javascript = { "template_string" },
		java = false,
	},
})
