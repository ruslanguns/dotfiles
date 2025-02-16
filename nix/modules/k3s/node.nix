{ serverAddr, tokenFile, ... }:
let
  tokenExists = builtins.pathExists tokenFile;
  _ =
    if !tokenExists then
      builtins.trace "⚠️  K3s will not be installed because the token file is missing."
    else
      null;
in
{
  imports = [
    ./common.nix
  ];

  services.k3s = {
    enable = tokenExists;
    role = "agent";
    serverAddr = serverAddr;
    tokenFile = tokenFile;
    clusterInit = true;
    extraFlags = toString [
      "--disable traefik"
      "--disable servicelb"
      "--disable local-storage"
      "--flannel-backend=none"
      "--cluster-cidr=10.42.0.0/16"
      "--service-cidr=10.43.0.0/16"
    ];
  };
}
