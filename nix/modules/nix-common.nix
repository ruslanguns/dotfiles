{
  pkgs,
  lib,
  inputs,
  username,
  hostname,
  shell,
  ...
}:
{
  time.timeZone = "Europe/Madrid";

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  programs.nix-ld.enable = true;

  # Enable QEMU Guest for Proxmox
  services.qemuGuest.enable = lib.mkDefault true;

  # Use the boot drive for grub
  boot.loader.grub.enable = lib.mkDefault true;
  boot.loader.grub.devices = [ "nodev" ];
  # boot.growPartition = lib.mkDefault true;

  networking.hostName = hostname;

  environment.pathsToLink = [ "/share/${shell}" ];
  environment.shells = [ pkgs.${shell} ];
  environment.enableAllTerminfo = true;
  environment.systemPackages = with pkgs; [
    curl
    gitMinimal
    age
    ssh-to-age
    neovim
    restic
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    extraConfig = ''
      PrintLastLog no
    '';
  };
  system.stateVersion = lib.mkDefault "24.11";

  nix = {
    settings = {
      trusted-users = [ username ];
      accept-flake-config = true;
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
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

    package = pkgs.nixVersions.stable;

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };

}
