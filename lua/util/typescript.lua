-- TypeScript helpers on top of vtsls (replaces the typescript-tools.nvim
-- `:TSTools*` commands). Everything goes through standard LSP code actions
-- and vtsls workspace commands.
local M = {}

local function code_action(kind, title)
	return function()
		vim.lsp.buf.code_action({
			context = { only = { kind }, diagnostics = {} },
			apply = true,
		})
		vim.notify(title, vim.log.levels.INFO)
	end
end

M.organize_imports = code_action("source.organizeImports", "Organized imports")
M.sort_imports = code_action("source.sortImports", "Sorted imports")
M.remove_unused = code_action("source.removeUnused.ts", "Removed unused")
M.add_missing_imports = code_action("source.addMissingImports.ts", "Added missing imports")
M.fix_all = code_action("source.fixAll.ts", "Fixed all")

--- Files importing the current file -> quickfix list.
function M.file_references()
	local client = vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })[1]
	if not client then
		vim.notify("vtsls is not attached to this buffer", vim.log.levels.WARN)
		return
	end
	client:exec_cmd({
		title = "File references",
		command = "typescript.findAllFileReferences",
		arguments = { vim.uri_from_bufnr(0) },
	}, { bufnr = 0 }, function(err, result)
		if err then
			vim.notify("File references failed: " .. tostring(err.message), vim.log.levels.ERROR)
			return
		end
		if not result or #result == 0 then
			vim.notify("No file references found", vim.log.levels.INFO)
			return
		end
		local items = vim.lsp.util.locations_to_items(result, client.offset_encoding)
		vim.fn.setqflist({}, " ", { title = "File references", items = items })
		vim.cmd("copen")
	end)
end

return M
