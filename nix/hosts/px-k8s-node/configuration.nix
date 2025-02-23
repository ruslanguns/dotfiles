{ pkgs, username, ... }:
let
  serverAddr = "https://192.168.1.103:6443";
  tokenFile = "/home/${username}/.env/k3s_token";
in
{
  imports = [
    (import ../../modules/k3s/node.nix {
      inherit pkgs serverAddr tokenFile;
    })
  ];

}
