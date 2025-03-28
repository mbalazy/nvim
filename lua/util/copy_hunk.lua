-- Function to copy the current Git hunk to clipboard
-- This should be added directly to your init.lua or a standalone file

-- Function to get the current Git hunk under the cursor
local function copy_current_hunk_to_clipboard()
	-- Check if we're in a git repository
	local is_git_repo = os.execute("git rev-parse --is-inside-work-tree &>/dev/null")
	if not is_git_repo then
		vim.notify("Not in a Git repository", vim.log.levels.ERROR)
		return
	end

	-- Get the current buffer content
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local buffer_content = table.concat(lines, "\n")

	-- Get the current file path relative to git root
	local file_cmd = "git rev-parse --show-toplevel"
	local file_handle = io.popen(file_cmd)
	local git_root = file_handle:read("*line")
	file_handle:close()

	local full_path = vim.fn.expand("%:p")
	local rel_path = string.sub(full_path, #git_root + 2) -- +2 to account for the trailing slash

	-- Get the current line number
	local current_line = vim.fn.line(".")

	-- Create a temporary file with the current buffer content
	local temp_file = os.tmpname()
	local temp_handle = io.open(temp_file, "w")
	if not temp_handle then
		vim.notify("Failed to create temporary file", vim.log.levels.ERROR)
		return
	end
	temp_handle:write(buffer_content)
	temp_handle:close()

	-- Use git show to get the content of the file in the index/HEAD
	local show_cmd = string.format('git show HEAD:"%s" 2>/dev/null || echo ""', rel_path)
	local show_handle = io.popen(show_cmd)
	local orig_content = show_handle:read("*all")
	show_handle:close()

	if orig_content == "" then
		-- If file doesn't exist in HEAD (e.g., it's a new file), create an empty file
		orig_content = ""
	end

	-- Create another temporary file with the original content
	local orig_file = os.tmpname()
	local orig_handle = io.open(orig_file, "w")
	if not orig_handle then
		os.remove(temp_file)
		vim.notify("Failed to create temporary file for original content", vim.log.levels.ERROR)
		return
	end
	orig_handle:write(orig_content)
	orig_handle:close()

	-- Use diff to compare the two files
	local diff_cmd = string.format('diff -U3 "%s" "%s"', orig_file, temp_file)
	local diff_handle = io.popen(diff_cmd)
	local diff_output = diff_handle:read("*all")
	diff_handle:close()

	-- Clean up temporary files
	os.remove(temp_file)
	os.remove(orig_file)

	if diff_output == "" then
		vim.notify("No changes found in the current file", vim.log.levels.ERROR)
		return
	end

	-- Parse the hunks to find the one containing our current line
	local hunks = {}
	local hunk_start_pattern = "^@@%s+%-(%d+),?(%d*)%s+%+(%d+),?(%d*)%s+@@"
	local hunk_start = 0
	local hunk_end = 0
	local hunk_header = ""
	local hunk_content = {}
	local in_hunk = false
	local added_lines = 0
	local removed_lines = 0

	for line in diff_output:gmatch("[^\r\n]+") do
		local old_start, old_count, new_start, new_count = line:match(hunk_start_pattern)

		if old_start then
			-- Start of a new hunk
			if in_hunk and #hunk_content > 0 then
				-- Save the previous hunk
				table.insert(hunks, {
					start_line = hunk_start,
					end_line = hunk_end,
					header = hunk_header,
					content = table.concat(hunk_content, "\n"),
				})
			end

			-- Initialize the new hunk
			old_start, new_start = tonumber(old_start), tonumber(new_start)
			old_count = tonumber(old_count ~= "" and old_count or "1")
			new_count = tonumber(new_count ~= "" and new_count or "1")

			hunk_start = new_start
			hunk_end = new_start + new_count - 1
			hunk_header = line
			hunk_content = { line }
			in_hunk = true
			added_lines = 0
			removed_lines = 0
		elseif in_hunk then
			-- Add the line to the current hunk
			table.insert(hunk_content, line)

			-- Adjust line counts based on additions/removals
			if line:sub(1, 1) == "+" then
				added_lines = added_lines + 1
			elseif line:sub(1, 1) == "-" then
				removed_lines = removed_lines + 1
			end
		end
	end

	-- Add the last hunk if there is one
	if in_hunk and #hunk_content > 0 then
		table.insert(hunks, {
			start_line = hunk_start,
			end_line = hunk_end,
			header = hunk_header,
			content = table.concat(hunk_content, "\n"),
		})
	end

	-- Find the hunk containing our current line
	local current_hunk = nil
	for _, hunk in ipairs(hunks) do
		if current_line >= hunk.start_line and current_line <= hunk.end_line then
			current_hunk = hunk
			break
		end
	end

	if not current_hunk then
		vim.notify("No hunk found at the current line", vim.log.levels.ERROR)
		return
	end

	-- Format the hunk for clipboard
	local filename = vim.fn.expand("%:t")

	-- Process the hunk content to remove diff indicators
	local lines = vim.split(current_hunk.content, "\n")
	local clean_lines = {}

	-- Skip the first line (the hunk header)
	for i = 2, #lines do
		local line = lines[i]
		-- Remove the + indicators from added lines, skip removed lines (starting with -)
		if line:sub(1, 1) == "+" then
			table.insert(clean_lines, line:sub(2))
		elseif line:sub(1, 1) ~= "-" then
			table.insert(clean_lines, line)
		end
	end

	local clean_content = table.concat(clean_lines, "\n")
	local hunk_text = clean_content

	-- Copy to clipboard
	vim.fn.setreg("+", hunk_text)
	vim.fn.setreg('"', hunk_text)

	vim.notify("Copied current hunk to clipboard", vim.log.levels.INFO)
end

-- Create command to use the function
vim.api.nvim_create_user_command("CopyHunk", function()
	copy_current_hunk_to_clipboard()
end, {})

-- Optionally, set up a keybinding
-- vim.keymap.set('n', '<leader>ch', copy_current_hunk_to_clipboard, { noremap = true, desc = "Copy current hunk to clipboard" })
