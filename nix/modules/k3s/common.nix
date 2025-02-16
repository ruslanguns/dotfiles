{
  pkgs,
  username,
  hostname,
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./../px-disk-config.nix
    ./../nix-common.nix
    ./../users.nix
    ./../age-setup.nix
  ];

  time.timeZone = "Europe/Madrid";

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = hostname;
  networking.firewall.allowedTCPPorts = [
    6443
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
  networking.enableIPv6 = false;

  programs.nix-ld.enable = true;

  environment.pathsToLink = [ "/share/bash" ];
  environment.shells = [ pkgs.bash ];
  environment.enableAllTerminfo = true;
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.yq-go
    pkgs.jq
  ];

  security.sudo.wheelNeedsPassword = false;

  home-manager.users.${username} = {
    imports = [
      ../../home/${username}/home-minimal.nix
    ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    extraConfig = ''
      PrintLastLog no
    '';
  };
}
