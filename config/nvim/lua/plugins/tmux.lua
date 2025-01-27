return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Move to left split" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Move to below split" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Move to above split" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Move to right split" },
    { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Move to previous split" },
  },
}
