return {
	"akinsho/bufferline.nvim",
	lazy = false,
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		local bg_color = "#11121D"
		require("bufferline").setup({
			options = {
				mode = "buffers",
				themable = true,
				numbers = "none",
				close_command = "bdelete! %d",
				right_mouse_command = "bdelete! %d",
				left_mouse_command = "buffer %d",
				middle_mouse_command = nil,
				indicator = {
					icon = "|",
					style = "icon",
				},
				buffer_close_icon = "",
				modified_icon = "●",
				close_icon = "",
				left_trunc_marker = "",
				right_trunc_marker = "",
				max_name_length = 30,
				max_prefix_length = 30,
				tab_size = 21,
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(count, level, diagnostics_dict, context)
					local icon = level:match("error") and " " or " "
					return " " .. icon .. count
				end,
				show_buffer_icons = true,
				show_buffer_close_icons = false,
				show_close_icon = false,
				show_tab_indicators = false,
				persist_buffer_sort = true,
				separator_style = "none",
				enforce_regular_tabs = false,
				always_show_bufferline = true,
				offsets = {
					{
						filetype = "NvimTree",
						text = "File Explorer",
						text_align = "center",
						separator = false,
					},
				},
			},
			highlights = {
				background = {
					bg = bg_color,
				},
				buffer_visible = {
					bg = bg_color,
				},
				buffer_selected = {
					bg = bg_color,
					bold = true,
					italic = false,
				},
				separator = {
					fg = bg_color,
					bg = bg_color,
				},
				separator_visible = {
					fg = bg_color,
					bg = bg_color,
				},
				separator_selected = {
					fg = bg_color,
					bg = bg_color,
				},
				offset_separator = {
					bg = bg_color,
				},
				fill = {
					bg = bg_color,
				},
			},
		})

		-- Your preferred buffer reordering mappings
		vim.keymap.set("n", "≤", "<Cmd>BufferLineMovePrev<CR>", {})
		vim.keymap.set("n", "≥", "<Cmd>BufferLineMoveNext<CR>", {})

		-- Additional useful mappings
		vim.keymap.set("n", "<A-h>", "<Cmd>BufferLineCyclePrev<CR>", {})
		vim.keymap.set("n", "<A-l>", "<Cmd>BufferLineCycleNext<CR>", {})
		vim.keymap.set("n", "<A-c>", "<Cmd>bdelete!<CR>", {})
		vim.keymap.set("n", "<A-p>", "<Cmd>BufferLineTogglePin<CR>", {})
	end,
}
