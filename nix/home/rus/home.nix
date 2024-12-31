{
  pkgs,
  username,
  nix-index-database,
  ...
}:
let
  unstable-packages = with pkgs.unstable; [
    bat
    bottom
    coreutils
    curl
    du-dust
    fd
    findutils
    fx
    git
    git-crypt
    htop
    jq
    killall
    mosh
    procs
    ripgrep
    sd
    tree
    unzip
    vim
    wget
    zip
    k9s
    kubernetes-helm
    krew
    deno
    kubectl
    nixfmt-rfc-style
    neovim
    python3
    go
    bun
    kustomize
    kubecolor
    fzf
    lua51Packages.luarocks-nix
    lua51Packages.lua
    fnm
  ];

  stable-packages = with pkgs; [
    # productivity
    mdcat
    httpie # A user-friendly cURL replacement
    lazygit # A simple terminal UI for git commands
    pass
    kubeseal
    stern
    apacheHttpd
    sshpass

    # key tools
    gh # for bootstrapping
    just

    # core languages
    rustup

    # rust stuff
    cargo-cache
    cargo-expand

    # local dev stuf
    mkcert
    httpie

    # treesitter
    tree-sitter

    # language servers
    nodePackages.vscode-langservers-extracted # html, css, json, eslint
    nodePackages.yaml-language-server
    nil # nix

    # formatters and linters
    alejandra # nix
    deadnix # nix
    nodePackages.prettier
    shellcheck
    shfmt
    statix # nix
    nixpkgs-fmt
    markdownlint-cli2
    sqlfluff
    stylua

    openssl
    xmlsec
    libxml2
    age.out
    ssh-to-age
    sops
    fluxcd
    kind
    speedtest-cli
    gdu
    lsof
    ltrace
    strace
    btop
    iftop

    # misc
    yq-go
    cowsay
    file
    which
    gnused
    gnutar
    gawk
    zstd
    gnupg
    gnumake

    # system
    glib
    gcc

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses
  ];
in
{
  imports = [
    nix-index-database.hmModules.nix-index
    ../../modules/zellij.nix
    ../../modules/starship.nix
    ../../modules/tmux.nix
    ../../modules/git.nix
    ../../modules/fish.nix
  ];

  home.stateVersion = "22.11";

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables.EDITOR = "nvim";
    sessionVariables.SHELL = "/etc/profiles/per-user/${username}/bin/fish";
  };

  home.packages = stable-packages ++ unstable-packages;

  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    nix-index.enableFishIntegration = true;
    nix-index-database.comma.enable = true;

    # fzf.enable = true;
    fzf.enableFishIntegration = true;
    lsd.enable = true;
    lsd.enableAliases = true;
    zoxide.enable = true;
    zoxide.enableFishIntegration = true;
    zoxide.options = [ "--cmd cd" ];
    broot.enable = true;
    broot.enableFishIntegration = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
  };

}
