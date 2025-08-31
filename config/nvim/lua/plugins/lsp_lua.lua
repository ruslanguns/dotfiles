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
          require("lspconfig").lua_ls.setup(opts)
          return true
        end,
      },
    },
  },
}
