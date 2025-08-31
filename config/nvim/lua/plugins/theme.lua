return {
  { "shaunsingh/nord.nvim" },
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      on_highlights = function(hl, c)
        hl.FloatBorder = { fg = c.blue, bg = "none" } -- border color for floating windows
        hl.WinSeparator = { fg = c.lightblue } -- border color for vertical split
      end,
    },
  },
  -- The LazyVim plugin configures your default colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
