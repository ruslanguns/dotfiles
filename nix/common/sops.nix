{
  inputs,
  config,
  username,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../secrets.yaml;
    validateSopsFiles = false;

    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

    secrets = {
      "users/${username}/password".neededForUsers = true;
      # Not in use if it's a good idea... better to have unique keys for each instance/user
      #"users/${username}/ssh_private_key" = {
      #  owner = username;
      #  mode = "0600";
      #  path = "/home/${username}/.ssh/id_ed25519";
      #};
      "users/${username}/kube_config_wob" = {
        owner = username;
        mode = "0600";
        path = "/home/${username}/.env/kube_config_wob";
      };

      "users/${username}/kube_config_rs" = {
        owner = username;
        mode = "0600";
        path = "/home/${username}/.env/kube_config_rs";
      };

      "users/${username}/kube_config_rus" = {
        owner = username;
        mode = "0600";
        path = "/home/${username}/.env/kube_config_rus";
      };

      "users/${username}/gpg_id" = {
        neededForUsers = true;
        owner = username;
        mode = "0600";
        path = "/home/${username}/.env/gpg_id";
      };

      "users/${username}/gpg_keys" = {
        neededForUsers = true;
        owner = username;
        mode = "0600";
        path = "/home/${username}/.env/gpg_keys";
      };

      "users/${username}/fish_config" = {
        neededForUsers = true;
        owner = username;
        mode = "0600";
        path = "/home/${username}/.env/fish_config.fish";
      };

      "users/${username}/backup_projects" = {
        neededForUsers = true;
        owner = username;
        mode = "0750";
        path = "/opt/backup_projects.sh";
      };
    };
  };

  # The containing folders are created as root and if this is the first ~/.config/ entry,
  # the ownership is busted and home-manager can't target because it can't write into .config...
  # (sops) We might not need this depending on how https://github.com/Mic92/sops-nix/issues/381 is fixed
  system.activationScripts.sopsSetAgeKeyOwnership =
    let
      user = config.users.users.${username}.name;
      group = config.users.users.${username}.group;
    in
    ''
      chown -R ${user}:${group} /home/${username}/.config
      chown -R ${user}:${group} /home/${username}/.env
      chown -R ${user}:${group} /run/secrets-for-users/users/${username}
    '';
}
