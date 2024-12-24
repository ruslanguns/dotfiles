local snacks = require("snacks")

return {
  "snacks.nvim",
  ---@type snacks.Config
  opts = {
    notifier = {
      enabled = true,
      top_down = false,
      style = "fancy",
    },
  },
}
