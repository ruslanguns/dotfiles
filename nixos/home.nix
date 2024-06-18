{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./packages
  ];

  nixpkgs = {
  #  overlays = [
  #    outputs.overlays.additions
  #    outputs.overlays.modifications
  #    outputs.overlays.unstable-packages
  #  ];
    config = {
      allowUnfree = true;
    };
  };

  home.username = "rus";
  home.homeDirectory = "/home/rus";
  home.packages = with pkgs; [
    # utils
    zip
    neofetch
    xz # A data compression tool
    unzip
    p7zip
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    wget # A network utility to retrieve files from the Web
    curl # A command line tool and library for transferring data with URL syntax
    fd # A simple, fast and user-friendly alternative to 'find'
    fzf # A command-line fuzzy finder
    bat # A cat(1) clone with wings
    ripgrep # recursively searches directories for a regex pattern
    tre-command # Tree command, improved
    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses
    networkmanager-openvpn # OpenVPN plugin for NetworkManager
    gnome.networkmanager-openvpn # OpenVPN plugin for NetworkManager
    openfortivpn # Fortinet compatible VPN client
    openvpn

    # system
    glib
    gcc

    # Fish
    oh-my-fish
    fishPlugins.done
    fishPlugins.fzf-fish
    fishPlugins.forgit
    fishPlugins.hydro
    fishPlugins.grc
    fzf
    fishPlugins.grc # Generic Colouriser
    grc # Generic Colouriser

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    gnumake

    # nix related
    nix-output-monitor
    nix-your-shell
    home-manager

    # productivity
    httpie # A user-friendly cURL replacement
    lazygit # A simple terminal UI for git commands
    tmux
    xclip # A command line interface to the X11 clipboard
    pass
    libreoffice
    

    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files
    gdu # disk usage interactive
    dust # disk usage statistics

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    psensor # hardware monitoring tool
    speedtest-cli

    # electron software
    gnome3.gnome-tweaks
    tela-circle-icon-theme
    vscode
    slack
    brave
    gitg
    element-desktop
    telegram-desktop
    mangohud
    protonup
    rocketchat-desktop
    obs-studio


    # programming langueges or interpreters or just utils
    asdf-vm
    python3
    nodejs
    lua
    stylua
    kubernetes
    kubecolor
    kubernetes-helm
    docker-compose
    kind
    go
    bun
    krew
    kustomize
    kubeval
    k9s
    cargo
    fluxcd
  ];

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "24.05";
}
