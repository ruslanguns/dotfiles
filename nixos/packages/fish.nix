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
    ls = "ls --color=auto --hide=\\*~ --hide=lost+found";
    ll = "ls -l";
    la = "ls -A";
    lla = "ls -lA";
    nixos-rebuild = "nixos-rebuild --use-remote-sudo";

  };

  programs.dircolors.enableFishIntegration = true;
}
