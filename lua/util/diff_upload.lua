local M = {}

local function log_message(message, level)
	level = level or vim.log.levels.INFO
	vim.notify(message, level)
end

local function generate_filename()
	local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
	local is_git_repo = os.execute("git rev-parse --is-inside-work-tree &>/dev/null")

	if is_git_repo then
		local repo_cmd = "basename $(git rev-parse --show-toplevel) 2>/dev/null || echo 'unknown_repo'"
		local repo_handle = io.popen(repo_cmd)
		local repo_name = repo_handle:read("*line")
		repo_handle:close()

		local branch_cmd = "git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown_branch'"
		local branch_handle = io.popen(branch_cmd)
		local branch_name = branch_handle:read("*line")
		branch_handle:close()

		branch_name = branch_name:gsub("/", "_")

		return timestamp .. "__" .. repo_name .. "__" .. branch_name .. ".diff"
	else
		local dir_cmd = "basename $(pwd)"
		local dir_handle = io.popen(dir_cmd)
		local dir_name = dir_handle:read("*line")
		dir_handle:close()

		local filename = vim.fn.expand("%:t")
		if filename == "" then
			filename = "nofile"
		end

		return timestamp .. "__" .. dir_name .. "__" .. filename .. ".diff"
	end
end

function M.create_and_upload_diff()
	local temp_file = os.tmpname()

	local is_git_repo = os.execute("git rev-parse --is-inside-work-tree &>/dev/null")

	local diff_cmd
	if is_git_repo then
		diff_cmd = "git diff > " .. temp_file
		log_message("Creating git diff...")
	else
		local current_file = vim.fn.expand("%:p")

		if current_file == "" then
			log_message("No file open. Cannot create diff.", vim.log.levels.ERROR)
			os.remove(temp_file)
			return
		end

		local buf_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
		local buf_temp = os.tmpname()

		local buf_file = io.open(buf_temp, "w")
		if not buf_file then
			log_message("Failed to open temp buffer file for writing", vim.log.levels.ERROR)
			os.remove(temp_file)
			return
		end

		buf_file:write(buf_content)
		buf_file:close()

		diff_cmd = "diff -u " .. current_file .. " " .. buf_temp .. " > " .. temp_file
		log_message("Creating file diff...")
	end

	local diff_success = os.execute(diff_cmd)

	if not is_git_repo then
		os.remove(buf_temp)
	end

	if not diff_success then
		log_message("Failed to create diff", vim.log.levels.ERROR)
		os.remove(temp_file)
		return
	end

	local remote_filename = generate_filename()

	local remote_dir = "/home/mart007/difs"
	local remote_path = remote_dir .. "/" .. remote_filename

	os.execute("ssh mydevil 'mkdir -p " .. remote_dir .. "'")

	log_message("Uploading diff to SSH...")

	local upload_cmd = "scp " .. temp_file .. " mydevil:" .. remote_path

	local upload_handle = io.popen(upload_cmd .. " 2>&1")
	local upload_output = upload_handle:read("*all")
	local _, exit_type, exit_code = upload_handle:close()

	local upload_success = (exit_code == 0 or exit_code == nil)
		and (upload_output == "" or not upload_output:match("failed") and not upload_output:match("error"))

	os.remove(temp_file)

	if upload_success then
		log_message("Diff uploaded successfully to " .. remote_path, vim.log.levels.INFO)
	else
		-- Try an alternative method only if there was an actual error message
		if upload_output:match("No such file") or upload_output:match("failed") or upload_output:match("error") then
			log_message("First upload attempt failed, trying alternative method")

			-- Alternative upload command with verbose output
			upload_cmd = "scp -v " .. temp_file .. " mydevil:" .. remote_path

			local alt_handle = io.popen(upload_cmd .. " 2>&1")
			local alt_output = alt_handle:read("*all")
			local _, alt_exit_type, alt_exit_code = alt_handle:close()

			-- Check if alternative method was successful
			upload_success = (alt_exit_code == 0 or alt_exit_code == nil)
				and (not alt_output:match("failed") and not alt_output:match("No such file"))
		end

		if upload_success then
			log_message("Diff uploaded successfully to " .. remote_path, vim.log.levels.INFO)
		else
			log_message("Failed to upload diff to SSH", vim.log.levels.ERROR)
		end
	end
end

return M
