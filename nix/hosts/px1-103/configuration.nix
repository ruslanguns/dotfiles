{ username, ... }:
let
  tokenFile = "/home/${username}/.env/k3s_token";
in
{
  imports = [
    (import ../../modules/k3s/master.nix {
      tokenFile = tokenFile;
    })
  ];
}
