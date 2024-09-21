return {
  "goolord/alpha-nvim",
  opts = function()
    local dashboard = require("alpha.themes.dashboard")
    local logo = [[
      ██████╗ ██╗   ██╗███████╗ ██████╗    ██████╗ ███████╗██╗   ██╗
      ██╔══██╗██║   ██║██╔════╝██╔═══██╗   ██╔══██╗██╔════╝██║   ██║
      ██████╔╝██║   ██║███████╗██║   ██║   ██║  ██║█████╗  ██║   ██║
      ██╔══██╗██║   ██║╚════██║██║   ██║   ██║  ██║██╔══╝  ╚██╗ ██╔╝
      ██║  ██║╚██████╔╝███████║╚██████╔╝██╗██████╔╝███████╗ ╚████╔╝ 
      ╚═╝  ╚═╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝╚═════╝ ╚══════╝  ╚═══╝  
                    @ruslangonzalez | @ruslanguns
    ]]
    dashboard.section.header.val = vim.split(logo, "\n")
    return dashboard
  end,
}
