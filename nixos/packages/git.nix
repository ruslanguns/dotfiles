{ inputs, outputs, lib, config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Ruslan Gonzalez";
    userEmail = "ruslanguns@gmail.com";
  };
}

