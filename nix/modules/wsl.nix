{ pkgs, username, ... }:
{

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    wslConf.interop.appendWindowsPath = false;
    wslConf.network.generateHosts = true;
    defaultUser = username;
    startMenuLaunchers = true;
    docker-desktop.enable = true;
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  programs.nix-ld.libraries = with pkgs; [
    libusb1
    zlib
    libftdi
    libudev0-shim
    libtool
    libusb-compat-0_1
  ];

  services.vscode-server.enable = true;
  networking.firewall.checkReversePath = "loose";
}
