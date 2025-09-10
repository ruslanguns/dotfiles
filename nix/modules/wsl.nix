{
  pkgs,
  username,
  win_user,
  lib,
  config,
  ...
}:
{

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    wslConf.interop.appendWindowsPath = false;
    wslConf.network.generateHosts = true;
    defaultUser = username;
    startMenuLaunchers = true;
    docker-desktop.enable = false;
    extraBin = with pkgs; [
      # Binaries for Docker Desktop wsl-distro-proxy
      { src = "${coreutils}/bin/mkdir"; }
      { src = "${coreutils}/bin/cat"; }
      { src = "${coreutils}/bin/whoami"; }
      { src = "${coreutils}/bin/ls"; }
      { src = "${busybox}/bin/addgroup"; }
      { src = "${su}/bin/groupadd"; }
      { src = "${su}/bin/usermod"; }
    ];
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  systemd.services.docker-desktop-proxy.script = lib.mkForce ''${config.wsl.wslConf.automount.root}/wsl/docker-desktop/docker-desktop-user-distro proxy --docker-desktop-root ${config.wsl.wslConf.automount.root}/wsl/docker-desktop "C:\Program Files\Docker\Docker\resources"'';

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

  environment.variables.PATH = [
    "/mnt/c/Users/${win_user}/scoop/apps/vscode/current/bin"
  ];

  services.vscode-server.enable = true;
  networking.firewall.checkReversePath = "loose";
}
