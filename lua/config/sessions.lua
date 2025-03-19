local M = {}
-- Session management keybindings for both Git repositories and regular directories

local function get_root()
	-- First try to get git root
	local git_dir = vim.fn.system("git rev-parse --show-toplevel 2> /dev/null"):gsub("\n", "")
	if vim.v.shell_error == 0 and git_dir ~= "" then
		return git_dir, true -- Return git directory and flag indicating it's a git repo
	end

	-- If not in a git repo, use current working directory
	return vim.fn.getcwd(), false
end

local function get_session_name()
	local root, is_git = get_root()
	if root then
		-- Convert path to a safe filename by replacing slashes
		local session_name = root:gsub("/", "_"):gsub(":", "_")
		if is_git then
			return "git_" .. session_name .. ".vim"
		else
			return "dir_" .. session_name .. ".vim"
		end
	end
	return nil
end

local function get_session_file()
	local session_name = get_session_name()
	if session_name then
		local session_dir = vim.fn.stdpath("data") .. "/sessions"
		return session_dir .. "/" .. session_name
	end
	return nil
end

local function save_session()
	local root, is_git = get_root()
	if not root then
		vim.notify("Could not determine root directory", vim.log.levels.WARN)
		return
	end

	local session_dir = vim.fn.stdpath("data") .. "/sessions"
	local session_file = get_session_file()

	-- Create session directory if it doesn't exist
	vim.fn.mkdir(session_dir, "p")

	vim.cmd("mksession! " .. session_file)

	local msg_prefix = is_git and "Git repository" or "Directory"
	vim.notify("Session saved for " .. msg_prefix .. ": " .. root, vim.log.levels.INFO)

	-- Set a global variable to track this session
	vim.g.active_session = session_file
end

local function load_session()
	local root, is_git = get_root()
	if not root then
		vim.notify("Could not determine root directory", vim.log.levels.WARN)
		return
	end

	local session_file = get_session_file()

	if vim.fn.filereadable(session_file) == 1 then
		vim.cmd("source " .. session_file)

		local msg_prefix = is_git and "Git repository" or "Directory"
		vim.notify("Session loaded for " .. msg_prefix .. ": " .. root, vim.log.levels.INFO)

		-- Set a global variable to track this session
		vim.g.active_session = session_file
	else
		local msg_prefix = is_git and "Git repository" or "Directory"
		vim.notify("No session found for " .. msg_prefix .. ": " .. root, vim.log.levels.WARN)
	end
end

-- Auto-update session when adding/deleting buffers or exiting Vim
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "VimLeave" }, {
	callback = function()
		if vim.g.active_session and vim.fn.filereadable(vim.g.active_session) == 1 then
			vim.cmd("mksession! " .. vim.g.active_session)
		end
	end,
})

M.save_session = save_session
M.load_session = load_session

vim.api.nvim_create_user_command("SessionLoad", function()
	load_session()
end, {
	desc = "Load session",
})

return M
