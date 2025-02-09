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
    # ../../modules/kubernetes/master.nix
  ];

  time.timeZone = "Europe/Madrid";

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.k3s = {
    enable = true;
    role = "server";
    token = "37Jl7t3wG0j9QvcxTTiejFId5JrlDhzL2cZwFWKleM5gkEN4UGQyS"; # Demo purposes only
    clusterInit = true;
  };
  networking.hostName = hostname;
  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJ1HLduJD+xCSVOnF8b9DrLp/DwHx9bxsoyGWdduJid ruslanguns@gmail.com | (huawei-wsl-01) NixOs"
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
