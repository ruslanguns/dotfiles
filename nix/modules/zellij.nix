{ pkgs, ... }:
let
  package = pkgs.unstable.zellij;
  src = pkgs.fetchFromGitHub {
    owner = "zellij-org";
    repo = "zellij";
    rev = "v${package.version}";
    sha256 = "0mvkx5d69v4046bi9jr35rd5f0kz4prf0g7ja9xyh1xllpg8giv1";
  };
in
{
  home.file.".config/zellij/themes" = {
    recursive = true;
    source = "${src}/zellij-utils/assets/themes";
  };

  programs.zellij = {
    enable = true;
    #enableFishIntegration = true;
    inherit package;
    settings = {
      theme = "onedark";
    };
  };
}
