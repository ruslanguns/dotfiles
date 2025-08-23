return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- For Lua
      opts.formatters = opts.formatters or {}
      opts.formatters.stylua = {
        prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
      }

      -- For YAML and others
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        sql = { "sql_formatter" },
        yaml = { "biome" },
        yml = { "biome" },
        ["yaml.ansible"] = { "biome" },
        ["yaml.gitlab"] = { "biome" },
        ["yaml.docker-compose"] = { "biome" },
        dockercompose = { "biome" },
        ["gitlab-ci"] = { "biome" },
      })
    end,
  },
}
