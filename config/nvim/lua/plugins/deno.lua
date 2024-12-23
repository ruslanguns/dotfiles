return {
  -- LSP Configuration & Plugins
  "neovim/nvim-lspconfig",
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    {
      "williamboman/mason.nvim",
      config = true,
      opts = {
        ensure_installed = {
          "eslint_lsp",
          "prettier",
          "denols", -- configure to support Deno
          "typescript-language-server",
        },
        automatic_installation = true,
      },
    },
    "williamboman/mason-lspconfig.nvim", -- Useful status updates for LSP
    -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
    { "j-hui/fidget.nvim", tag = "legacy", opts = {} },
  },
}
