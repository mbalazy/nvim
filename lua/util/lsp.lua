local M = {}

-- Organise imports
M.typescript_organise_imports = {
    description = "Organise Imports",
    function()
        local params = {
            command = "_typescript.organizeImports",
            arguments = { vim.fn.expand("%:p") },
        }
        -- reorganise imports
        vim.lsp.buf.execute_command(params)
    end,
}

return M
