return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "ngx" } },
              format = {
                enable = false,
              },
            },
          },
        },
      },
      setup = {
        lua_ls = function(_, opts)
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "lua",
            callback = function()
              vim.opt_local.shiftwidth = 4
              vim.opt_local.tabstop = 4
              vim.opt_local.softtabstop = 4
              vim.opt_local.expandtab = true
            end,
          })
          require("lspconfig").lua_ls.setup(opts)
          return true
        end,
      },
    },
  },
}
