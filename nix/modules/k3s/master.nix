{
  pkgs,
  tokenFile,
  ...
}:
{
  imports = [ ./common.nix ];

  services.k3s = {
    enable = true;
    role = "server";
    package = pkgs.k3s_1_30;
    tokenFile = tokenFile;
    clusterInit = true;
    extraFlags = toString [
      "--flannel-backend=none"
      "--disable-network-policy"
      "--disable=servicelb"
      # "--disable=traefik"
    ];
    manifests = {
      cilium = {
        enable = true; # First time must be installed manually
        target = "cilium.yaml";
        source = ./manifests/cilium.yaml;
      };
      longhorn = {
        enable = true;
        target = "longhorn.yaml";
        source = ./manifests/longhorn.yaml;
      };
      kyverno = {
        enable = true;
        target = "kyverno.yaml";
        source = ./manifests/kyverno.yaml;
      };
      sealedSecrets = {
        enable = true;
        target = "sealed-secrets.yaml";
        source = ./manifests/sealed-secrets.yaml;
      };
      longhornAddNixOsPath = {
        enable = true;
        target = "longhorn-add-nixos-path.yaml";
        source = ./manifests/longhorn-add-nixos-path.yaml;
      };
    };
  };
}
