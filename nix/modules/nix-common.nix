{
  pkgs,
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

  networking.hostName = hostname;

  environment.pathsToLink = [ "/share/${shell}" ];
  environment.shells = [ pkgs.${shell} ];
  environment.enableAllTerminfo = true;
  environment.systemPackages = with pkgs; [
    curl
    gitMinimal
    age.out
    ssh-to-age
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    extraConfig = ''
      PrintLastLog no
    '';
  };
  system.stateVersion = "24.05";

  nix = {
    settings = {
      trusted-users = [ username ];
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
