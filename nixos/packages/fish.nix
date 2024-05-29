{ inputs, outputs, lib, config, pkgs, ... }:

{
  programs.fish.enable = true;
  programs.fish.shellInit = ''
    set fish_greeting '''
    set EDITOR 'nvim'
    set -gx PATH $PATH $HOME/.krew/bin
  '';

  programs.fish.shellAliases = {
    kubectl = "kubecolor";
    k = "kubecolor";
    ll = "eza -l";
    ls = "eza";
    la = "eza -A";
    lla = "eza -lA";

  };

  programs.dircolors.enableFishIntegration = true;
}
