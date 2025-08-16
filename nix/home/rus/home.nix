{
  pkgs,
  username,
  nix-index-database,
  shell,
  ...
}:
let
  unstable-packages = with pkgs.unstable; [
    # CLI Utilities
    bat
    bottom
    coreutils
    curl
    du-dust
    fd
    findutils
    fx
    fzf
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
    xclip
    xorg.xauth

    # Kubernetes & Cloud
    cilium-cli
    fluxcd
    k9s
    istioctl
    kind
    cloud-provider-kind
    kubebuilder
    kubecolor
    kubectl
    kustomize
    kubeval
    kubernetes-helm
    helmfile
    krew
    operator-sdk
    opentofu
    terragrunt
    terraform
    terraformer
    ansible

    # Development
    bun
    deno
    fnm
    go
    jdk
    neovim
    nixfmt-rfc-style
    python313
    python313Packages.ipython
    python313Packages.markdown-it-py
    python313Packages.pylatexenc
    lua51Packages.luarocks-nix
    lua51Packages.tiktoken_core
    lua51Packages.lua

    # Build Tools
    cmake
    ninja
    atuin

    # Hardware & Embedded
    esptool
    libusbp
    mpremote
    openocd
    picocom

    # GIS
    osmium-tool
    osmctools
    tilemaker

    # Documents
    json-schema-for-humans
  ];

  stable-packages = with pkgs; [
    # CLI Utilities & Productivity
    _1password-cli
    aichat
    argc
    bitwarden-cli
    btop
    cowsay
    file
    gawk
    gdu
    gettext
    gh
    gnumake
    gnupg
    gnused
    gnutar
    gum
    httpie
    iftop
    just
    lazygit
    lsof
    ltrace
    lynx
    mdcat
    pass
    speedtest-cli
    sshpass
    stern
    strace
    which
    yq-go
    zstd

    # Development
    # Languages
    julia
    php
    php84Packages.composer
    ruby
    rustup
    # Rust Tools
    cargo-cache
    cargo-expand
    # Local Dev
    mkcert
    # Language Servers & Tooling
    marksman
    nil
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    tree-sitter
    # Formatters & Linters
    alejandra
    ast-grep
    deadnix
    gofumpt
    gosimports
    markdownlint-cli2
    nixpkgs-fmt
    nodePackages.prettier
    shellcheck
    shfmt
    sql-formatter
    sqlfluff
    statix
    stylua
    yamlfmt
    biome
    yamllint

    # Kubernetes
    kubeseal

    # Networking
    apacheHttpd
    aria2
    dnsutils
    ipcalc
    iperf3
    ldns
    mtr
    nmap
    socat
    traceroute

    # VPN
    openfortivpn
    openvpn
    wireguard-tools
    tailscale

    # Security
    age
    libxml2
    openssl
    sops
    ssh-to-age
    xmlsec

    # Media & Images
    chafa
    ghostscript
    imagemagick
    ueberzugpp
    viu

    # Documents
    mermaid-cli
    tectonic

    # System
    gcc
    glib
  ];
in
{
  imports = [
    nix-index-database.homeModules.nix-index
    ../../modules/zellij.nix
    ../../modules/starship.nix
    ../../modules/tmux.nix
    ../../modules/git.nix
    ../../modules/fish.nix
  ];

  home.stateVersion = "25.05";

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables.EDITOR = "nvim";
    sessionVariables.SHELL = "/etc/profiles/per-user/${username}/bin/${shell}";
  };

  home.packages = stable-packages ++ unstable-packages;

  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    nix-index.enableFishIntegration = true;
    nix-index-database.comma.enable = true;

    fzf.enableFishIntegration = true;
    lsd.enable = true;
    lsd.enableFishIntegration = true;
    zoxide.enable = true;
    zoxide.enableFishIntegration = true;
    zoxide.options = [ "--cmd cd" ];
    broot.enable = true;
    broot.enableFishIntegration = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
  };

}
