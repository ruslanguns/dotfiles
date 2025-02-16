{
  modulesPath,
  lib,
  username,
  hostname,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./../../modules/px-disk-config.nix
    ./../../modules/users.nix
  ];

  time.timeZone = "Europe/Madrid";

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  programs.nix-ld.enable = true;

  networking.hostName = hostname;

  environment.pathsToLink = [ "/share/bash" ];
  environment.shells = [ pkgs.bash ];
  environment.enableAllTerminfo = true;
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    extraConfig = ''
      PrintLastLog no
    '';
  };

  home-manager.users.${username} = {
    imports = [
      ../../../home/${username}/home.nix
    ];
  };
}
