return {
  "folke/tokyonight.nvim",
  opts = {
    transparent = true,
    styles = {
      sidebars = "transparent",
      floats = "transparent",
    },
    on_highlights = function(hl, c)
      hl.FloatBorder = { fg = c.blue, bg = "none" }
      hl.WinSeparator = { fg = c.lightblue } -- border color for vertical split
    end,
  },
}
