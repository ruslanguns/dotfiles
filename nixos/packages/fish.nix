{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.fish.enable = true;
  programs.fish.shellInit = ''
    set fish_greeting '''
    set EDITOR 'nvim'
    set -gx PATH $PATH $HOME/.krew/bin

    if test -f ~/.alias
      source ~/.alias
    end

    abbr --add --global k kubectl
    '';

  programs.fish.interactiveShellInit = ''
    if command -q nix-your-shell
      nix-your-shell fish | source
    end
  '';

  programs.fish.shellAliases = {
    kubectl = "kubecolor";
    ll = "eza -l";
    ls = "eza";
    la = "eza -A";
    lla = "eza -lA";
    xcopy = "xclip -selection clipboard";
    xpaste = "xclip -selection clipboard -o";
  };

  programs.dircolors.enableFishIntegration = true;
}
