{
  pkgs,
  lib,
  username,
  ...
}:
{
  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [
      "wheel"
    ];

    openssh.authorizedKeys.keys =
      let
        keysFileRaw = builtins.readFile ../../config/ssh/authorized_keys;
        keysFile = lib.strings.splitString "\n" keysFileRaw;
        validKeys = lib.filter (key: key != "") keysFile;
      in
      validKeys;

  };
}
