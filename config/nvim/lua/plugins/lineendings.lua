return {
    {
        "LazyVim/LazyVim",
        opts = function()
            vim.opt.fileformat = "unix"
            vim.opt.fileformats = { "unix", "dos" }

            -- Auto-fix CRLF on save
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("FixCRLF", { clear = true }),
                pattern = "*",
                callback = function()
                    local save_cursor = vim.fn.getpos(".")
                    vim.cmd([[%s/\r$//e]])
                    vim.fn.setpos(".", save_cursor)
                end,
            })
        end,
    },
}
