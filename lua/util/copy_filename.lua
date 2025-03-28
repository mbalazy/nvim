local M = {}

-- Function to copy the current file name to clipboard
local function copy_filename(include_path, absolute_path)
  -- Get the current buffer's file name
  local current_file = vim.fn.expand("%")
  
  -- If no file is open, notify and return
  if current_file == "" then
    vim.notify("No file open", vim.log.levels.WARN)
    return
  end
  
  local result = current_file
  
  -- Handle different formatting options
  if not include_path then
    -- Extract just the filename without path
    result = vim.fn.fnamemodify(current_file, ":t")
  elseif absolute_path then
    -- Get absolute path
    result = vim.fn.fnamemodify(current_file, ":p")
  end
  
  -- Copy to clipboard
  vim.fn.setreg("+", result)
  vim.fn.setreg('"', result)
  
  -- Notify user
  vim.notify("Copied to clipboard: " .. result, vim.log.levels.INFO)
end

-- Function to copy just the filename without path
function M.copy_filename_only()
  copy_filename(false, false)
end

-- Function to copy relative path and filename
function M.copy_filename_with_path()
  copy_filename(true, false)
end

-- Function to copy absolute path and filename
function M.copy_filename_with_absolute_path()
  copy_filename(true, true)
end

-- Create user commands
vim.api.nvim_create_user_command("CopyFilename", function()
  M.copy_filename_only()
end, {
  desc = "Copy current filename to clipboard",
})

vim.api.nvim_create_user_command("CopyFilePath", function()
  M.copy_filename_with_path()
end, {
  desc = "Copy current file path to clipboard",
})

vim.api.nvim_create_user_command("CopyFileAbsolutePath", function()
  M.copy_filename_with_absolute_path()
end, {
  desc = "Copy current file absolute path to clipboard",
})

return M
