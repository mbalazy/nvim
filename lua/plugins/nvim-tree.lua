return {
  enabled = false,
	"nvim-tree/nvim-tree.lua",
	config = function()
		local api = require("nvim-tree.api")

		-- Setup the plugin
		require("nvim-tree").setup({
			sort = {
				sorter = "name",
				folders_first = true,
				files_first = false,
			},
			renderer = {
				group_empty = true,
			},
			filters = {
				dotfiles = false,
			},
			update_focused_file = {
				enable = true,
				update_root = {
					enable = true,
					ignore_list = {},
				},
				exclude = false,
			},
			git = {
				enable = true,
				show_on_dirs = true,
				show_on_open_dirs = true,
				disable_for_dirs = {},
				timeout = 400,
				cygwin_support = false,
			},
			view = {
				adaptive_size = true,
				centralize_selection = true,
				width = 30,
				cursorline = true,
				debounce_delay = 15,
				side = "left",
				preserve_window_proportions = false,
				number = false,
				relativenumber = false,
				signcolumn = "yes",
			},
			actions = {
				use_system_clipboard = true,
				change_dir = {
					enable = true,
					global = false,
					restrict_above_cwd = false,
				},
				expand_all = {
					max_folder_discovery = 300,
					exclude = {},
				},
				file_popup = {
					open_win_config = {
						col = 1,
						row = 1,
						relative = "cursor",
						border = "shadow",
						style = "minimal",
					},
				},
				open_file = {
					quit_on_open = true,
					eject = true,
				},
				remove_file = {
					close_window = true,
				},
			},
			on_attach = function(bufnr)
				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				-- default mappings
				api.config.mappings.default_on_attach(bufnr)

				-- custom mappings
				vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
				vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
				vim.keymap.set("n", "C", api.tree.change_root_to_node, opts("CD"))
			end,
		})
	end,
	cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeFindFileToggle" },
	event = "User DirOpened",
	lazy = false,
	dependencies = {
		"ibhagwan/fzf-lua", -- Required for the fzf-lua functions
	},
}
