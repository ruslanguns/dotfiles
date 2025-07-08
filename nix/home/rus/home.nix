{
  pkgs,
  username,
  nix-index-database,
  shell,
  ...
}:
let
  unstable-packages = with pkgs.unstable; [
    # Utilities
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
    json-schema-for-humans
    xclip
    xorg.xauth

    # Kubernetes
    k9s
    kubernetes-helm
    krew
    kubectl
    kustomize
    kubecolor
    kubeval
    operator-sdk
    kubebuilder
    fluxcd
    kind
    cilium-cli
    terragrunt
    opentofu
    terraform
    terraformer

    # Development Tools
    deno
    nixfmt-rfc-style
    neovim
    python313
    python313Packages.notebook
    python313Packages.ipython
    python313Packages.ipykernel
    python313Packages.jupyter
    python313Packages.jupyterlab
    python313Packages.jupyter-lsp
    python313Packages.jupyter-core
    python313Packages.jupyterlab-lsp
    python313Packages.jupyterlab-git
    python313Packages.jupyterlab-widgets
    python313Packages.pip
    python313Packages.numpy
    python313Packages.pandas
    python313Packages.matplotlib
    python313Packages.cookiecutter
    python313Packages.polars
    python313Packages.deltalake
    python313Packages.python-keycloak
    go
    bun
    fzf
    lua51Packages.luarocks-nix
    lua51Packages.lua
    fnm
    biome
    jdk
    esptool
    picocom
    mpremote
    libusbp
    openocd
    cmake
    ninja
    osmium-tool
    tilemaker
    osmctools
  ];

  stable-packages = with pkgs; [
    # Productivity
    mdcat
    httpie
    lazygit
    pass
    kubeseal
    stern
    apacheHttpd
    sshpass
    _1password-cli
    aichat

    # Key Tools
    gh
    just
    argc

    # Core Languages
    rustup
    julia

    # Rust Tools
    cargo-cache
    cargo-expand

    # Local Development
    mkcert
    httpie

    # Treesitter
    tree-sitter

    # Language Servers
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    nil
    marksman

    # Formatters and Linters
    alejandra
    deadnix
    nodePackages.prettier
    shellcheck
    shfmt
    statix
    nixpkgs-fmt
    markdownlint-cli2
    sqlfluff
    stylua

    # Security and Encryption
    openssl
    xmlsec
    libxml2
    age
    ssh-to-age
    sops

    # Network Tools
    mtr
    iperf3
    dnsutils
    ldns
    aria2
    socat
    nmap
    ipcalc

    # VPN Tools
    openfortivpn
    wireguard-tools
    openvpn

    # Miscellaneous
    speedtest-cli
    gdu
    lsof
    ltrace
    strace
    btop
    iftop
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
    gettext

    # System Tools
    glib
    gcc
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

  home.stateVersion = "24.11";

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
