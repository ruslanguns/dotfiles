{ username, ... }:
let
  serverAddr = "192.168.1.103";
  tokenFile = "/home/${username}/.env/k3s_token";
in
{
  imports = [
    (import ../../modules/k3s/node.nix {
      serverAddr = serverAddr;
      tokenFile = tokenFile;
    })
  ];

}
