return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      nil_ls = {
        settings = {
          ["nil"] = {
            nix = { flake = { autoArchive = true } },
          },
        },
      },
    },
  },
}
