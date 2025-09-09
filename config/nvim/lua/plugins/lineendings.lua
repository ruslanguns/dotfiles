return {
  {
    "LazyVim/LazyVim",
    opts = function()
      -- Set defaults without modifying the current buffer
      vim.opt_global.fileformat = "unix"
      vim.opt.fileformats = { "unix", "dos" }
    end,
  },
}
