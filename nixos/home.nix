{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports = [
    ./packages
  ];
  
  home.username = "rus";
  home.homeDirectory = "/home/rus";
  home.packages = with pkgs; [
    gnome3.gnome-shell
    gnome3.gnome-weather

    # utils
    zip
    neofetch
    xz
    unzip
    p7zip
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    gnumake #  A utility for directing compilation
    fd # A simple, fast and user-friendly alternative to 'find'
    wget # A network utility to retrieve files from the Web
    curl # A command line tool and library for transferring data with URL syntax
    bat # A cat(1) clone with wings
    
    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses
    networkmanager-openvpn # OpenVPN plugin for NetworkManager
    gnome.networkmanager-openvpn # OpenVPN plugin for NetworkManager
    openfortivpn # Fortinet compatible VPN client
    openvpn

    # system 
    glib
    gcc
    asdf-vm

    # Fish
    oh-my-fish
    fishPlugins.done
    fishPlugins.fzf-fish
    fishPlugins.forgit
    fishPlugins.hydro
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

    # nix related
    nix-output-monitor
    home-manager

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal
    httpie  # A user-friendly cURL replacement
    wl-clipboard
    lazygit # A simple terminal UI for git commands
    tmux

    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    psensor # hardware monitoring tool

    # electron software
    tela-circle-icon-theme
    #vscode
    (pkgs.writeShellApplication {
      name = "code";
      text = "${pkgs.vscode}/bin/code --use-gl=desktop";
    })
    (pkgs.makeDesktopItem {
      name = "code";
      exec = "code";
      desktopName = "Visual Studio Code";
      icon = "${pkgs.tela-circle-icon-theme}/share/icons/Tela-circle/scalable/apps/code.svg";
    })
    #slack
    (pkgs.writeShellApplication {
      name = "slack";
      text = "${pkgs.slack}/bin/slack --use-gl=desktop";
    })
    (pkgs.makeDesktopItem {
      name = "slack";
      exec = "slack";
      desktopName = "Slack";
      icon = "${pkgs.tela-circle-icon-theme}/share/icons/Tela-circle/scalable/apps/slack.svg";
    })
    # brave
    (pkgs.writeShellApplication {
      name = "brave";
      text = "${pkgs.brave}/bin/brave --use-gl=desktop";
    })
    (pkgs.makeDesktopItem {
      name = "brave";
      exec = "brave";
      desktopName = "Brave";
      icon = "${pkgs.tela-circle-icon-theme}/share/icons/Tela-circle/scalable/apps/brave.svg";
    })

    # programming langueges or interpreters or just utils
    python3
    nodejs
    lua
    stylua
    kubernetes
    kubecolor
    podman
    podman-tui
    kubernetes-helm
    docker-compose
    kind
    go
    bun

    krew # fixme: this should work with kubectl
    kustomize
    kubeval
    k9s
    cargo
    fluxcd
  ];

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
