return {
	"akinsho/bufferline.nvim",
	lazy = false,
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
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
					-- icon = " ", -- A subtle indicator
					-- icon = "|", -- A subtle indicator
					-- icon = "▎", -- A subtle indicator
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
				diagnostics_indicator = function(count, level)
					local icon = level:match("error") and " " or " "
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
				name_formatter = function(buf)
					-- Add spaces on both sides of each buffer name for visual separation
					return "  " .. buf.name .. "  "
				end,
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
				fill = {
					bg = "NONE",
				},
				background = {
					bg = "NONE",
				},
				tab = {
					bg = "NONE",
				},
				tab_selected = {
					bg = "NONE",
				},
				tab_close = {
					bg = "NONE",
				},
				buffer_visible = {
					bg = "NONE",
				},
				buffer_selected = {
					bg = "NONE",
					bold = true,
					italic = false,
				},
				separator = {
					fg = "NONE",
					bg = "NONE",
				},
				separator_selected = {
					fg = "NONE",
					bg = "NONE",
				},
				separator_visible = {
					fg = "NONE",
					bg = "NONE",
				},
				duplicate = {
					bg = "NONE",
				},
				duplicate_selected = {
					bg = "NONE",
				},
				duplicate_visible = {
					bg = "NONE",
				},
				modified = {
					bg = "NONE",
				},
				modified_selected = {
					bg = "NONE",
				},
				modified_visible = {
					bg = "NONE",
				},
				indicator_selected = {
					bg = "NONE",
				},
			},
		})
	end,
}
