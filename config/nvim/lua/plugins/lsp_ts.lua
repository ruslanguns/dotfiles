return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            vtsls = {
              tsserver = { format = { enable = false } },
            },
          },
        },
        denols = {
          root_dir = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc"),
        },
      },
      setup = {
        vtsls = function(_, opts)
          require("lspconfig").vtsls.setup(opts)
          return true
        end,
        denols = function(_, opts)
          require("lspconfig").denols.setup(opts)
          return true
        end,
      },
    },
  },
}
