-- Function to browse commit history and navigate to files
local function browse_commit_files(selected_commit_hash)
	local ok, Snacks = pcall(require, "snacks")
	if not ok then
		vim.notify("Snacks.nvim is not available", vim.log.levels.ERROR)
		return
	end

	-- Helper function to run git commands and return the output
	local function git_command(cmd)
		local handle = io.popen("git " .. cmd)
		if not handle then
			vim.notify("Failed to execute git command: " .. cmd, vim.log.levels.ERROR)
			return ""
		end

		local result = handle:read("*a")
		handle:close()
		return result
	end

	-- Get all commits on the current branch
	local function get_commits()
		-- Get the current branch
		local current_branch = git_command("branch --show-current"):gsub("%s+$", "")

		-- Get commit history for the current branch
		local commits_raw = git_command('log --pretty=format:"%h|%s|%an|%ar" ' .. current_branch)
		local commits = {}

		for line in commits_raw:gmatch("[^\r\n]+") do
			local hash, subject, author, date = line:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)")
			if hash and subject then
				table.insert(commits, {
					hash = hash,
					subject = subject,
					author = author,
					date = date,
					-- Format for display in the picker
					text = hash .. " (" .. date .. ") " .. subject .. " - " .. author,
				})
			end
		end

		return commits
	end

	-- Get files changed in a specific commit
	local function get_commit_files(commit_hash)
		-- Use a different git command to get a clean list of just the files
		local files_raw = git_command("diff-tree --no-commit-id --name-only -r " .. commit_hash)

		-- Process each line as a separate file
		local files = {}
		for file in files_raw:gmatch("[^\r\n]+") do
			if file ~= "" then
				-- Create items for the picker
				table.insert(files, {
					path = file,
					text = file, -- Display text for the picker
				})
			end
		end

		return files
	end

	-- Step 1: Show commits picker
	local commits = get_commits()
	if #commits == 0 then
		vim.notify("No commits found on the current branch", vim.log.levels.WARN)
		return
	end

	-- Find the index of the selected commit if provided
	local selected_index = 1
	if selected_commit_hash then
		for i, commit in ipairs(commits) do
			if commit.hash == selected_commit_hash then
				selected_index = i
				break
			end
		end
	end

	-- Create a custom preview function for git commits
	local function preview_commit(ctx)
		local commit_item = ctx.item
		if not commit_item or not commit_item.hash then
			return false
		end

		-- Get the commit diff
		local diff = git_command("show " .. commit_item.hash)
		if not diff or diff == "" then
			return false
		end

		-- Make the buffer modifiable
		vim.bo[ctx.buf].modifiable = true

		-- Set the preview content using vim API
		local lines = {}
		for line in diff:gmatch("([^\n]*)\n?") do
			table.insert(lines, line)
		end

		vim.api.nvim_buf_set_lines(ctx.buf, 0, -1, false, lines)

		-- Set the filetype to git/diff for proper syntax highlighting
		vim.bo[ctx.buf].filetype = "diff"

		-- Set the buffer back to not modifiable
		vim.bo[ctx.buf].modifiable = false

		return true
	end

	-- Based on documentation examples, use custom items directly
	Snacks.picker.pick({
		items = commits, -- Use 'items' instead of 'source' for custom data
		title = "Git Commits", -- Title for the picker
		format = "text", -- Use a standard format
		preview = preview_commit, -- Use our custom preview function
		prompt = "> ",
		on_show = function(picker)
			-- Set the cursor to the previously selected commit if any
			if selected_commit_hash then
				picker.list:view(selected_index)
			end
		end,
		confirm = function(commits_picker, commit_item)
			if not commit_item or not commit_item.hash then
				vim.notify("No commit selected", vim.log.levels.WARN)
				return
			end

			local commit_hash = commit_item.hash

			-- Step 2: Show files picker for the selected commit
			local files = get_commit_files(commit_hash)
			if #files == 0 then
				vim.notify("No files changed in this commit", vim.log.levels.WARN)
				return
			end

			-- Create a custom preview function for files in a commit
			local function preview_file(ctx)
				local file_item = ctx.item
				if not file_item or not file_item.path then
					return false
				end

				-- Get the file content from this commit
				local file_content = git_command("show " .. commit_hash .. ":" .. file_item.path)
				if not file_content or file_content == "" then
					return false
				end

				-- Make the buffer modifiable
				vim.bo[ctx.buf].modifiable = true

				-- Set the preview content using vim API
				local lines = {}
				for line in file_content:gmatch("([^\n]*)\n?") do
					table.insert(lines, line)
				end

				vim.api.nvim_buf_set_lines(ctx.buf, 0, -1, false, lines)

				-- Set the filetype for proper syntax highlighting based on the file extension
				local filetype = vim.filetype.match({ filename = file_item.path })
				if filetype then
					vim.bo[ctx.buf].filetype = filetype
				end

				-- Set the buffer back to not modifiable
				vim.bo[ctx.buf].modifiable = false

				return true
			end

			-- Show files picker with our file items
			Snacks.picker.pick({
				items = files, -- Pass our file items here
				title = "Changed Files in Commit " .. commit_hash:sub(1, 7),
				format = "text", -- Use text format for display
				preview = preview_file, -- Use our custom preview function
				prompt = "> ",
				-- Add custom action for going back to commits
				actions = {
					go_back = function(files_picker)
						files_picker:close()
						-- Start a new browser session with the current commit selected
						vim.schedule(function()
							browse_commit_files(commit_hash)
						end)
					end,
				},
				win = {
					input = {
						keys = {
							-- Add a backspace key binding to go back
							["<BS>"] = { "go_back", mode = { "n", "i" }, desc = "Go back to commits" },
							-- Add a b key binding to go back (alternative)
							["b"] = { "go_back", mode = "n", desc = "Go back to commits" },
						},
					},
					list = {
						keys = {
							-- Add the same bindings to the list window
							["<BS>"] = { "go_back", desc = "Go back to commits" },
							["b"] = { "go_back", desc = "Go back to commits" },
						},
					},
				},
				confirm = function(files_picker, file_item)
					if not file_item or not file_item.path then
						vim.notify("No file selected", vim.log.levels.WARN)
						return
					end

					-- Close the picker before opening the file
					files_picker:close()

					-- Step 3: Open the selected file
					local file_path = file_item.path

					-- Check if file exists in the current working tree
					local current_file_exists = vim.fn.filereadable(file_path) == 1

					if current_file_exists then
						-- Open the file in the current working tree
						vim.cmd.edit(file_path)
					else
						-- If file doesn't exist in the current working tree,
						-- open it from the specific commit
						vim.notify(
							"File doesn't exist in the current working tree, showing version from commit",
							vim.log.levels.WARN
						)

						-- Create a temporary file with the content from the commit
						local temp_dir = vim.fn.tempname()
						vim.fn.mkdir(temp_dir, "p")
						local temp_file = temp_dir .. "/" .. vim.fn.fnamemodify(file_path, ":t")

						-- Extract file content from the commit
						local file_content = git_command("show " .. commit_hash .. ":" .. file_path)
						local file_handle = io.open(temp_file, "w")
						if file_handle then
							file_handle:write(file_content)
							file_handle:close()

							-- Open the temporary file
							vim.cmd.edit(temp_file)
							-- Set buffer as readonly
							vim.opt_local.readonly = true
							-- Set buffer title to show it's from a commit
							vim.api.nvim_buf_set_name(0, file_path .. " [" .. commit_hash .. "]")
						else
							vim.notify("Failed to create temporary file", vim.log.levels.ERROR)
						end
					end
				end,
			})
		end,
	})
end

-- Create a user command for easy access
vim.api.nvim_create_user_command("BrowseCommitFiles", function()
	browse_commit_files()
end, {
	desc = "Browse commit history and navigate to files",
})

-- You can also add a keymap for easier access
-- vim.keymap.set("n", "<leader>gc", browse_commit_files, { desc = "Browse commit files" })

return {
	browse_commit_files = browse_commit_files,
}
