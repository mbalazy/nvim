local M = {}

local function format_diagnostic(diagnostic, bufname)
	local severity = ""
	if diagnostic.severity == 1 then
		severity = "Error"
	elseif diagnostic.severity == 2 then
		severity = "Warning"
	elseif diagnostic.severity == 3 then
		severity = "Information"
	elseif diagnostic.severity == 4 then
		severity = "Hint"
	end

	local line = diagnostic.lnum + 1 -- Convert to 1-based line numbering
	local col = diagnostic.col + 1 -- Convert to 1-based column numbering
	local message = diagnostic.message:gsub("\n", " ") -- Replace newlines with spaces

	-- Format: [Severity] File:line:col: Message
	return string.format("[%s] %s:%d:%d: %s", severity, bufname, line, col, message)
end

-- Function to copy all diagnostics to clipboard
function M.copy_diagnostics_to_clipboard()
	local all_diagnostics = {}

	-- Get diagnostics for all buffers
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")
			-- Skip unnamed buffers
			if bufname ~= "" then
				local diagnostics = vim.diagnostic.get(bufnr)
				for _, diagnostic in ipairs(diagnostics) do
					table.insert(all_diagnostics, format_diagnostic(diagnostic, bufname))
				end
			end
		end
	end

	-- Check if we found any diagnostics
	if #all_diagnostics == 0 then
		vim.notify("No diagnostics found", vim.log.levels.INFO)
		return
	end

	-- Add a header with count and timestamp
	local header = string.format("LSP Diagnostics (%d issues) - %s\n", #all_diagnostics, os.date("%Y-%m-%d %H:%M:%S"))

	-- Sort diagnostics by severity (errors first)
	table.sort(all_diagnostics, function(a, b)
		-- Simple sort based on the severity tag at the beginning
		if a:match("^%[Error%]") and not b:match("^%[Error%]") then
			return true
		elseif not a:match("^%[Error%]") and b:match("^%[Error%]") then
			return false
		elseif a:match("^%[Warning%]") and not b:match("^%[Warning%]") and not b:match("^%[Error%]") then
			return true
		else
			return false
		end
	end)

	-- Concatenate all diagnostics with newlines
	local content = header .. table.concat(all_diagnostics, "\n")

	-- Copy to clipboard
	vim.fn.setreg("+", content)
	vim.fn.setreg('"', content)

	vim.notify(string.format("Copied %d diagnostics to clipboard", #all_diagnostics), vim.log.levels.INFO)
end

return M
