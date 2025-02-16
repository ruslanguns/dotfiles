let
  serverAddr = "192.168.1.103";
  tokenFile = "";
in
{
  imports = [
    (import ../../modules/k3s/node.nix {
      master_ip = serverAddr;
      tokenFile = tokenFile;
    })
  ];

}
