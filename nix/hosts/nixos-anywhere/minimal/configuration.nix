{
  modulesPath,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  programs.nix-ld.enable = true;
  programs.fish.enable = true;

  environment.pathsToLink = [ "/share/fish" ];
  environment.shells = [ pkgs.fish ];
  environment.enableAllTerminfo = true;
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuamihqruTuItFfvmn7NRoYSGpDQrDpzo02ezd9VHRj ruslanguns@gmail.com | WSL (main) NixOS
"
  ];

  system.stateVersion = "24.05";

  registry = {
    nixpkgs = {
      flake = inputs.nixpkgs;
    };
  };

  gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  };
}
