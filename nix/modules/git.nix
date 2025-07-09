{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.unstable.git;
    delta.enable = true;
    delta.options = {
      line-numbers = true;
      side-by-side = true;
      navigate = true;
    };
    userEmail = "ruslanguns@gmail.com";
    userName = "Ruslan Gonzalez";
    extraConfig = {
      # url = {
      #   "https://oauth2:${secrets.github_token}@github.com" = {
      #     insteadOf = "https://github.com";
      #   };
      #   "https://oauth2:${secrets.gitlab_token}@gitlab.com" = {
      #     insteadOf = "https://gitlab.com";
      #   };
      # };
      init = {
        defaultBranch = "main";
      };
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      merge = {
        conflictstyle = "diff3";
      };
      diff = {
        colorMoved = "default";
      };
      pull = {
        rebase = true;
      };
      core = {
        autocrlf = "input";
      };
    };
  };
}
