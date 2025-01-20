{
  modulesPath,
  lib,
  hostname,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ../../modules/kubernetes/node.nix
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

  users.users.root = {
    shell = pkgs.bash;
    hashedPassword = "$y$j9T$sS8OCdNMTNR.Auy4MLVLZ0$lobIV1wwpAyOiUJ97RGstNWYiqnQRi8Az0QumufbLN5";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuamihqruTuItFfvmn7NRoYSGpDQrDpzo02ezd9VHRj ruslanguns@gmail.com | (desktop-wsl-01) NixOS"
    ];
  };

  system.stateVersion = "24.05";

  nix = {
    settings = {
      accept-flake-config = true;
      auto-optimise-store = true;
    };

    registry = {
      nixpkgs = {
        flake = inputs.nixpkgs;
      };
    };

    nixPath = [
      "nixpkgs=${inputs.nixpkgs.outPath}"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];

    package = pkgs.nixFlakes;
    extraOptions = ''experimental-features = nix-command flakes'';

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };
}
