{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = true;
      line_break.disabled = true;
      kubernetes = {
        symbol = "☸️ ";
        style = "bold blue";
      };
    };
  };
}
