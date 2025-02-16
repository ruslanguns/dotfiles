let
  tokenFile = "";
in
{
  imports = [
    (import ../../modules/k3s/master.nix {
      tokenFile = tokenFile;
    })
  ];
}
