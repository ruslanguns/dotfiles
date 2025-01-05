{
  pkgs,
  win_user,
  username,
  ...
}:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

      ${pkgs.lib.strings.fileContents (
        pkgs.fetchFromGitHub {
          owner = "rebelot";
          repo = "kanagawa.nvim";
          rev = "de7fb5f5de25ab45ec6039e33c80aeecc891dd92";
          sha256 = "sha256-f/CUR0vhMJ1sZgztmVTPvmsAgp0kjFov843Mabdzvqo=";
        }
        + "/extras/kanagawa.fish"
      )}

      set -U fish_greeting

      set -q KREW_ROOT
      set -gx PATH $PATH $KREW_ROOT/.krew/bin;
      set -gx PATH $PATH $HOME/.krew/bin

      fish_add_path --append /mnt/c/Users/${win_user}/scoop/apps/win32yank/0.1.1

      set NIX_MSG ${username}

      set fish_config_file "/home/${username}/.env/fish_config.fish"

      if test -f $fish_config_file
        source $fish_config_file
      end

      # fnm
      set PATH "/home/${username}/.local/share/fnm" $PATH
      fnm env | source
    '';
    functions = {
      refresh = "source $HOME/.config/fish/config.fish";
      take = ''mkdir -p -- "$1" && cd -- "$1"'';
      ttake = "cd $(mktemp -d)";
      show_path = "echo $PATH | tr ' ' '\n'";
      hello = "echo Hello, $USER";
      posix-source = ''
        for i in (cat $argv)
          set arr (echo $i |tr = \n)
          set -gx $arr[1] $arr[2]
        end
      '';
      kubectl = "kubecolor $argv";
    };
    shellAbbrs =
      {
        k = "kubectl";
        kcu = "kubectl ctx -u";
        kc = "kubectl ctx";
      }
      # nix shortcuts
      // {
        nrp = "nix run nixpkgs#";
        nrs = "sudo nixos-rebuild switch --flake ~/.dotfiles/nix/";
        gc = "nix-collect-garbage --delete-old";
      }
      # navigation shortcuts
      // {
        ".." = "cd ..";
        "..." = "cd ../../";
        "...." = "cd ../../../";
        "....." = "cd ../../../../";
      }
      # git shortcuts
      // {
        gapa = "git add --patch";
        grpa = "git reset --patch";
        gst = "git status";
        gdh = "git diff HEAD";
        gp = "git push";
        gph = "git push -u origin HEAD";
        gco = "git checkout";
        gcob = "git checkout -b";
        gcm = "git checkout master";
        gcd = "git checkout develop";
        gsp = "git stash push -m";
        gsa = "git stash apply stash^{/";
        gsl = "git stash list";
      };
    shellAliases = {
      xcopy = "/mnt/c/Windows/System32/clip.exe";
      xpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
      explorer = "/mnt/c/Windows/explorer.exe";
      code = "/mnt/c/Users/${win_user}/scoop/apps/vscode/current/bin/code";
      vim = "nvim";
      vi = "nvim";
    };
    plugins = [
      {
        inherit (pkgs.fishPlugins.autopair) src;
        name = "autopair";
      }
      {
        inherit (pkgs.fishPlugins.done) src;
        name = "done";
      }
      {
        inherit (pkgs.fishPlugins.sponge) src;
        name = "sponge";
      }
    ];
  };

}
