{
  modulesPath,
  username,
  config,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./../../modules/users.nix
    ./../../modules/nix-common.nix
    ./../../modules/px-disk-config.nix
  ];

  users.mutableUsers = false;
  users.users.${username}.hashedPasswordFile = config.sops.secrets."users/${username}/password".path;

  home-manager.users.${username} = {
    imports = [
      ../../home/${username}/home.nix
    ];
  };

  networking.firewall.enable = false;
}
