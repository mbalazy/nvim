-- Buffer tabs (replaces bufferline.nvim). Minimal: names + icons, current buffer
-- highlighted, modified marker. Switching: <S-h>/<S-l>, <leader>, (picker).
return {
	"nvim-mini/mini.tabline",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		show_icons = true,
		format = function(buf_id, label)
			local suffix = vim.bo[buf_id].modified and "● " or ""
			return " " .. MiniTabline.default_format(buf_id, label) .. suffix .. " "
		end,
		tabpage_section = "right",
	},
}
