-- Function to compare selected branch with HEAD using Diffview and Snacks.picker
local function compare_with_branch_picker()
	local ok, Snacks = pcall(require, "snacks")
	if not ok then
		vim.notify("Snacks.nvim is not available", vim.log.levels.ERROR)
		return
	end

	-- Use Snacks.picker's built-in git_branches source
	Snacks.picker.pick({
		source = "git_branches",
		confirm = function(_, item)
			if item then
				-- Log the full item structure for debugging
				vim.notify("Selected item: " .. vim.inspect(item), vim.log.levels.DEBUG)

				-- Try different potential properties where the branch name might be stored
			  local branch = item.branch

				if branch then
					vim.notify("Selected branch: " .. vim.inspect(branch), vim.log.levels.INFO)
					vim.cmd("DiffviewOpen " .. branch .. "..HEAD")
				else
					vim.notify("Could not determine branch name from selection", vim.log.levels.WARN)
				end
			else
				vim.notify("No branch selected", vim.log.levels.WARN)
			end
		end,
	})
end

vim.api.nvim_create_user_command("CompareBranch", function()
	compare_with_branch_picker()
end, {
	desc = "Compare current branch with another branch using Diffview",
})
