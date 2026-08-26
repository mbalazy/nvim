local function git_stash_with_name()
	-- Check if we're in a git repository
	local is_git = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):match("true")
	if not is_git then
		vim.notify("Not in a git repository", vim.log.levels.ERROR)
		return
	end

	-- Check if there are changes to stash (including untracked files)
	local has_tracked_changes = vim.fn.system("git status --porcelain -uno 2>/dev/null")
	local has_untracked_changes = vim.fn.system("git ls-files --others --exclude-standard 2>/dev/null")

	if has_tracked_changes == "" and has_untracked_changes == "" then
		vim.notify("No changes to stash", vim.log.levels.WARN)
		return
	end

	-- Create an input prompt for the stash name
	vim.ui.input({
		prompt = "Stash name: ",
		default = "",
		completion = "file",
	}, function(name)
		-- If user cancels or provides empty name, abort
		if not name or name == "" then
			vim.notify("Stash operation cancelled", vim.log.levels.INFO)
			return
		end

		-- Create the stash with the provided name, including untracked files with -u
		local result = vim.fn.system({ "git", "stash", "push", "-u", "-m", name })

		-- Check if the stash was successful
		if vim.v.shell_error == 0 then
			vim.notify("Created stash with untracked files: " .. name, vim.log.levels.INFO)
		else
			vim.notify("Failed to create stash: " .. result, vim.log.levels.ERROR)
		end
	end)
end

-- Register the function globally
_G.git_stash_with_name = git_stash_with_name

-- Create a user command for it
vim.api.nvim_create_user_command("GitStashNamed", function()
	git_stash_with_name()
end, {})
