{
  pkgs,
  serverAddr,
  tokenFile,
  ...
}:
{
  imports = [
    ./common.nix
  ];

  services.k3s = {
    enable = true;
    role = "agent";
    package = pkgs.k3s_1_30;
    serverAddr = serverAddr;
    tokenFile = tokenFile;
  };
}
