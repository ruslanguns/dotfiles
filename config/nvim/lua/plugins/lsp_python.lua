return {
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      require("dap-python").setup("/etc/profiles/per-user/rus/bin/python")
    end,
  },
}
