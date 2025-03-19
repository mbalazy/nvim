-- Function to compare selected branch with HEAD using Diffview and Snacks.picker
function compare_with_branch_picker()
	-- Check if Snacks is available
	local ok, Snacks = pcall(require, "snacks")
	if not ok then
		vim.notify("Snacks.nvim is not available", vim.log.levels.ERROR)
		return
	end

	-- Run git command to get only local branches
	local handle = io.popen("git branch --format='%(refname:short)'")
	if not handle then
		vim.notify("Failed to run git command", vim.log.levels.ERROR)
		return
	end

	local result = handle:read("*a")
	handle:close()

	-- Split the result into an array of branch names
	local branches = {}
	for branch in result:gmatch("[^\r\n]+") do
		table.insert(branches, { text = branch, value = branch })
	end

	-- Use Snacks.picker to display branches for selection
	Snacks.picker.pick({
		items = branches,
		title = "Git Branches",
		prompt = "Select branch to compare with HEAD",
		confirm = function(picker, item)
			picker:close()
			if item and item.value then
				local branch = item.value

				-- Debug: print the selected branch
				vim.notify("Selected branch: " .. vim.inspect(branch), vim.log.levels.INFO)

				-- Execute the diffview command
				vim.cmd("DiffviewOpen " .. branch .. "..HEAD")
			else
				vim.notify("No branch selected", vim.log.levels.WARN)
			end
		end,
	})
end

-- Create the user command
vim.api.nvim_create_user_command("CompareBranch", function()
	compare_with_branch_picker()
end, {
	desc = "Compare current branch with another branch using Diffview",
})

