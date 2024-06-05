{ inputs, outputs, lib, config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Ruslan Gonzalez";
    userEmail = "ruslanguns@gmail.com";
    extraConfig = {
      gpg = {
        format = "ssh";
      };
      "gpg \"ssh\"" = {
        program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
      commit = {
        gpgsign = true;
      };

      user = {
        signingKey = "F51A70311EAFA649";
      };
    };
  };
}

