{
  modulesPath,
  username,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./../../modules/px-disk-config.nix
    ./../../modules/users.nix
    ./../../modules/nix-common.nix
  ];

  home-manager.users.${username} = {
    imports = [
      ../../home/${username}/home.nix
    ];
  };
}
