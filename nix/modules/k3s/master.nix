{
  pkgs,
  tokenFile,
  ...
}:
let
  infra = pkgs.stdenv.mkDerivation {
    name = "infra";
    src = ../k8s;
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };
in
{
  imports = [ ./common.nix ];

  systemd.services.bootstrap-install = {
    description = "Install Kubernetes Bootstrap Infrastructure (CNI)";
    after = [ "k3s.service" ];
    path = [
      pkgs.kubernetes-helm
      pkgs.kubectl
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "install-infrastructure" ''
        set -e
        export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

        TEMP_DIR=$(mktemp -d)
        cp -r ${infra}/* $TEMP_DIR/
        cd $TEMP_DIR

        helmfile apply -f $TEMP_DIR/helmfile.yaml

        rm -rf $TEMP_DIR
      '';
    };
  };

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
  };
}
