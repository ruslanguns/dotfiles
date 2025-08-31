if true then
  return {}
end
return {
  {
    "lewis6991/hover.nvim",
    config = function()
      require("hover").setup({})
      local gid = vim.api.nvim_create_augroup("hover_plugin_mouse", { clear = true })
      vim.o.mouse = "a"
      vim.o.mousemoveevent = true
      local timer = vim.loop.new_timer()
      local waiting = false
      local function debounced()
        if waiting then
          return
        end
        waiting = true
        timer:start(200, 0, function()
          waiting = false
          vim.schedule(function()
            pcall(require("hover").hover)
          end)
        end)
      end
      vim.api.nvim_create_autocmd("MouseMove", { group = gid, pattern = "*", callback = debounced })
    end,
  },
}
