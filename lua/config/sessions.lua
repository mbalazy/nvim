local M = {}
-- Session management keybindings for Git repositories
local function get_git_root()
  local git_dir = vim.fn.system("git rev-parse --show-toplevel 2> /dev/null"):gsub("\n", "")
  if vim.v.shell_error == 0 and git_dir ~= "" then
    return git_dir  -- Return git_dir, not git_root (which doesn't exist)
  end
  return nil
end

local function get_session_name()
	local git_root = get_git_root()
	if git_root then
		-- Convert git root path to a safe filename by replacing slashes
		local session_name = git_root:gsub("/", "_"):gsub(":", "_")
		return session_name .. ".vim"
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

local function save_git_session()
	local git_root = get_git_root()
	if not git_root then
		vim.notify("Not in a Git repository", vim.log.levels.WARN)
		return
	end

	local session_dir = vim.fn.stdpath("data") .. "/sessions"
	local session_file = get_session_file()

	-- Create session directory if it doesn't exist
	vim.fn.mkdir(session_dir, "p")

	vim.cmd("mksession! " .. session_file)
	vim.notify("Session saved for: " .. git_root, vim.log.levels.INFO)

	-- Set a global variable to track this session
	vim.g.active_git_session = session_file
end

local function load_git_session()
	local git_root = get_git_root()
	if not git_root then
		vim.notify("Not in a Git repository", vim.log.levels.WARN)
		return
	end

	local session_file = get_session_file()

	if vim.fn.filereadable(session_file) == 1 then
		vim.cmd("source " .. session_file)
		vim.notify("Session loaded for: " .. git_root, vim.log.levels.INFO)

		-- Set a global variable to track this session
		vim.g.active_git_session = session_file
	else
		vim.notify("No session found for: " .. git_root, vim.log.levels.WARN)
	end
end

-- Auto-update session when adding/deleting buffers or exiting Vim
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "VimLeave" }, {
	callback = function()
		if vim.g.active_git_session and vim.fn.filereadable(vim.g.active_git_session) == 1 then
			vim.cmd("mksession! " .. vim.g.active_git_session)
		end
	end,
})

M.save_git_session = save_git_session
M.load_git_session = load_git_session

return M
