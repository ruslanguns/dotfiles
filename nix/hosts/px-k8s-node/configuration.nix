{
  pkgs,
  username,
  hostname,
  serverIp,
  ...
}:
let
  serverAddr = "https://${serverIp}:6443";
  tokenFile = "/home/${username}/.env/k3s_token";
in
{
  imports = [
    (import ../../modules/k3s/node.nix {
      inherit
        pkgs
        serverAddr
        tokenFile
        hostname
        ;
    })
  ];

}
