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
        yaml = { "yamlfmt" },
        yml = { "yamlfmt" },
        ["yaml.ansible"] = { "yamlfmt" },
        ["yaml.gitlab"] = { "yamlfmt" },
        ["yaml.docker-compose"] = { "yamlfmt" },
        dockercompose = { "yamlfmt" },
        ["gitlab-ci"] = { "yamlfmt" },
      })
    end,
  },
}
