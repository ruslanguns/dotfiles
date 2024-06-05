{ inputs, outputs, lib, config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Ruslan Gonzalez";
    userEmail = "ruslanguns@gmail.com";
    extraConfig = {
      user = {
        signingKey = "F51A70311EAFA649";
      };
    };
  };
}

