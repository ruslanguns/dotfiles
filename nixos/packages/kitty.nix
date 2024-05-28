{ lib, config, pkgs, ... }:

{
 programs.kitty = {
   enable = true;
   font = {
     name = "Fira Code";
     package = pkgs.fira-code;
     size = 14;
   };
   settings = {
     enable_audio_bell = false;
    };
    theme = "Everforest Dark Medium";
  };
}
