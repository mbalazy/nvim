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

local config = function()
	-- local palette = require("nightfox.palette").load("carbonfox")
	-- local custom_nightfox = require("lualine.themes.nightfox")
	-- custom_nightfox.normal.b.bg = palette.bg0

	require("lualine").setup({
		options = {
			-- theme = custom_nightfox,
			globalstatus = true,
			component_separators = { left = "", right = "|" },
			section_separators = { left = "", right = "" },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff" }, -- Add branch name here
			lualine_c = {
				{ "filename", file_status = true, newfile_status = false, path = 3, shorting_target = 30 },
			},
			lualine_x = { "progress", { searchCount } },
			lualine_y = { "" },
			lualine_z = { "location" },
		},
		tabline = {},
	})
end

return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	config = config,
}
