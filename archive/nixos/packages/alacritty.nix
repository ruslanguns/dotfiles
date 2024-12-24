{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 13;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };
}
