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
      "--disable-kube-proxy"
      "--disable=traefik"
      "--disable=servicelb"
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
      kubeVip = {
        enable = true;
        target = "kube-vip.yaml";
        source = ./manifests/kube-vip.yaml;
      };
      ddns = {
        enable = true;
        target = "ddns.yaml";
        source = ./manifests/ddns.yaml;
      };
      ingress = {
        enable = true;
        target = "ingress.yaml";
        source = ./manifests/ingress.yaml;
      };
    };
  };
}
