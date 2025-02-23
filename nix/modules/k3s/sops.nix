{
  inputs,
  username,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./k3s-secrets.yaml;
    validateSopsFiles = false;

    secrets = {
      "k3s_token" = {
        owner = username;
        mode = "0600";
        path = "/home/${username}/.env/k3s_token";
      };
    };
  };
}
