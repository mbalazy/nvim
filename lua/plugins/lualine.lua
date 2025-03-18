local function searchCount()
	local search = vim.fn.searchcount({ maxcount = 0 }) -- maxcount = 0 makes the number not be capped at 99
	local searchCurrent = search.current
	local searchTotal = search.total

	if searchCurrent > 0 and vim.v.hlsearch == 1 then
		return "/" .. vim.fn.getreg("/") .. " [" .. searchCurrent .. "/" .. searchTotal .. "]"
	else
		return ""
	end
end

-- Global variable to track path display state, must be global for refresh to work
_G.lualine_show_path = false

-- Function to toggle file path visibility
local function toggle_file_path()
	_G.lualine_show_path = not _G.lualine_show_path
	require("lualine").refresh()
end

local config = function()
	local colors = {
		fg = "#c3ccdc",
		fg_dim = "#a5b0c5",

		bg = "NONE",
		bg_highlight = "NONE",
	}

	local custom_theme = {
		normal = {
			a = { fg = colors.fg, bg = colors.bg, gui = "bold" },
			b = { fg = colors.fg, bg = colors.bg },
			c = { fg = colors.fg_dim, bg = colors.bg },
		},
		insert = {
			a = { fg = "#93cee9", bg = colors.bg, gui = "bold" },
			b = { fg = colors.fg, bg = colors.bg },
			c = { fg = colors.fg_dim, bg = colors.bg },
		},
		visual = {
			a = { fg = "#c4a7e7", bg = colors.bg, gui = "bold" },
			b = { fg = colors.fg, bg = colors.bg },
			c = { fg = colors.fg_dim, bg = colors.bg },
		},
		replace = {
			a = { fg = "#ea9a97", bg = colors.bg, gui = "bold" },
			b = { fg = colors.fg, bg = colors.bg },
			c = { fg = colors.fg_dim, bg = colors.bg },
		},
		command = {
			a = { fg = "#a3be8c", bg = colors.bg, gui = "bold" },
			b = { fg = colors.fg, bg = colors.bg },
			c = { fg = colors.fg_dim, bg = colors.bg },
		},
		inactive = {
			a = { fg = colors.fg_dim, bg = colors.bg },
			b = { fg = colors.fg_dim, bg = colors.bg },
			c = { fg = colors.fg_dim, bg = colors.bg },
		},
	}

	-- Custom filename component that fully hides when toggle is off
	local filename_component = {
		"filename",
		cond = function()
			return _G.lualine_show_path
		end,
		file_status = true,
		newfile_status = false,
		path = 3,
		shorting_target = 30,
	}

	require("lualine").setup({
		options = {
			theme = custom_theme,
			globalstatus = true,
			component_separators = { left = "", right = "|" },
			section_separators = { left = "", right = "" },
			disabled_filetypes = {
				statusline = {},
				winbar = {},
			},
			ignore_focus = {},
			always_divide_middle = true,
			refresh = {
				statusline = 1000,
				tabline = 1000,
				winbar = 1000,
			},
		},
		sections = {
			lualine_a = { "" },
			lualine_b = { "branch" }, -- Add branch name here
			lualine_c = { filename_component },
			lualine_x = { "progress", { searchCount } },
			lualine_y = { "" },
			lualine_z = { "location" },
		},
		tabline = {},
	})

	vim.keymap.set(
		"n",
		"<leader>uf",
		toggle_file_path,
		{ noremap = true, silent = true, desc = "Toggle file path in statusline" }
	)
end

return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	config = config,
}
