{
  username,
  config,
  ...
}:
{
  imports = [
    ./../../modules/nix-common.nix
    ./../../modules/users.nix
    ./../../modules/wsl.nix
    ./../../modules/sops.nix
  ];

  users.mutableUsers = false;
  users.users.${username}.hashedPasswordFile = config.sops.secrets."users/${username}/password".path;

  home-manager.users.${username} = {
    imports = [
      ../../home/${username}/home.nix
    ];
  };
}
