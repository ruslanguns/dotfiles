{
  pkgs,
  lib,
  username,
  shell,
  ...
}:
{
  programs = lib.optionalAttrs (shell != "bash") {
    ${shell}.enable = true;
  };

  security.sudo.wheelNeedsPassword = false;

  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.${shell};
    extraGroups = [
      "wheel"
      "docker"
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
