-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- vim.g.lazyvim_prettier_needs_config = true
-- opts.rocks.hererocks = false;
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff"
vim.opt.wrap = true
-- Set default fileformat for new buffers only
vim.opt_global.fileformat = "unix"
vim.opt.fileformats = { "unix", "dos" }

-- Strip CRLF only for modifiable file buffers
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    if vim.bo.buftype == "" and vim.bo.modifiable then
      vim.cmd([[%s/\r$//e]])
    end
  end,
})
