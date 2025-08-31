-- Disabled
if true then
  return {}
end

return {
  {
    "lewis6991/hover.nvim",
    event = { "LspAttach" },
    opts = {
      init = function()
        require("hover.providers.lsp")
      end,
      preview_opts = { border = "single" },
      preview_window = false,
      title = true,
      mouse_providers = { "LSP" },
      mouse_delay = 1000,
    },
    config = function(_, opts)
      require("hover").setup(opts)
      vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
      vim.keymap.set("n", "gK", require("hover").hover_select, { desc = "hover.nvim (select)" })
      vim.keymap.set("n", "<C-p>", function()
        local pos = vim.api.nvim_win_get_cursor(0)
        require("hover").hover_switch("previous", { bufnr = 0, pos = { line = pos[1], col = pos[2] } })
      end, { desc = "hover.nvim (previous source)" })
      vim.keymap.set("n", "<C-n>", function()
        local pos = vim.api.nvim_win_get_cursor(0)
        require("hover").hover_switch("next", { bufnr = 0, pos = { line = pos[1], col = pos[2] } })
      end, { desc = "hover.nvim (next source)" })
      vim.keymap.set("n", "<MouseMove>", require("hover").hover_mouse, { desc = "hover.nvim (mouse)" })
      vim.o.mousemoveevent = true
    end,
  },
}
