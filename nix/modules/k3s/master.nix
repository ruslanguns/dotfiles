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
        enable = false;
        target = "cilium.yaml";
        source = ./manifests/cilium.yaml;
      };
    };
  };

}
