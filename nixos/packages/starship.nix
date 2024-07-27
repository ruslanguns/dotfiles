{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = true;
      kubernetes = {
        disabled = false;
        format = "[ $symbol$user:[($namespace)](bold red)](dimmed blue) ";
      };
    };
  };
}
