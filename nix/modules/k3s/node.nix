{ serverAddr, tokenFile, ... }:
{
  imports = [
    ./common.nix
  ];

  services.k3s = {
    enable = false;
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
