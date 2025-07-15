{
  pkgs,
  username,
  nix-index-database,
  ...
}:
let
  unstable-packages = with pkgs.unstable; [
    # Utilities
    bat
    coreutils
    curl
    du-dust
    fd
    findutils
    fx
    jq
    sd
    tree
    vim
    wget
  ];

  stable-packages = with pkgs; [
    # Network Tools
    mtr
    iperf3
    dnsutils
    ldns
    aria2
    nmap
    kubernetes-helm
    cilium-cli
  ];
in
{
  imports = [
    nix-index-database.hmModules.nix-index
  ];

  home.stateVersion = "25.05";

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
  };

  home.packages = stable-packages ++ unstable-packages;

  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    nix-index-database.comma.enable = true;
    bash.enable = true;
    lsd.enable = true;
    lsd.enableFishIntegration = true;
    zoxide.enable = true;
    zoxide.enableBashIntegration = true;
    zoxide.options = [ "--cmd cd" ];
    broot.enable = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
  };
}
