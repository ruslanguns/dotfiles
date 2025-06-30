{
  pkgs,
  win_user,
  username,
  lib,
  isWSL,
  ...
}:
let
  isLinux = pkgs.stdenv.isLinux && !isWSL;
  isMac = pkgs.stdenv.isDarwin;
in
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

      if test -d ~/.dotfiles/scripts/
        set -gx PATH $PATH $HOME/.dotfiles/scripts
      end

      set NIX_MSG ${username}

      # load dynamic settings
      set fish_config_file "/home/${username}/.env/fish_config.fish"
      if test -f $fish_config_file
        source $fish_config_file
      end

      # fnm
      set PATH "/home/${username}/.local/share/fnm" $PATH
      fnm env | source

      set -gx PATH $PATH (fnm env --shell=fish | source)

      type -q ensure_krew_plugins; and ensure_krew_plugins 2>/dev/null
      type -q ensure_nodejs; and ensure_nodejs 2>/dev/null
    '';
    functions = lib.mkMerge [
      {
        refresh = "history --save; source $HOME/.config/fish/config.fish; echo '✨ Fish config reloaded successfully! 🚀'; exec fish";
        take = ''mkdir -p -- "$1" && cd -- "$1"'';
        ttake = "cd $(mktemp -d)";
        show_path = "echo $PATH | tr ' ' '\n'";
        posix-source = ''
          for i in (cat $argv)
            set arr (echo $i |tr = \n)
            set -gx $arr[1] $arr[2]
          end
        '';
        kubectl = "kubecolor $argv";
        justnix = "just -f ~/.dotfiles/Justfile $argv";
        ensure_nodejs = ''
          if not fnm list | grep -q "v22.17.0"
              echo "📦 [fnm] Installing Node.js v22.17.0"
              fnm install 22.17.0
              echo "✅ [fnm] Node.js v22.17.0 is already installed"
          end

          if not test (fnm current) = "v22.17.0"
              echo "🔧 Setting Node.js v22.17.0 as default"
              fnm default 22.17.0
          end
        '';
        ensure_krew_plugins = ''
          set plugins ns ctx foreach apidocs argo-apps-viz cilium count ctr df-pv kyverno kubescape resource-capacity stern view-utilization view-quotas modify-secret view-secret unused-volumes
          set installed 0

          for plugin in $plugins
              set escaped (string escape --style=regex -- $plugin)
              set pattern "^$escaped\$"

              if not krew list | grep -q $pattern
                  echo "📦 [krew] installing plugin: $plugin"
                  if krew install $plugin > /dev/null 2>&1
                      set installed (math $installed + 1)
                  else
                      echo "[krew] failed to install plugin: $plugin" >&2
                  end
              end
          end

          if test $installed -gt 0
              echo "✅ [krew] $installed plugin(s) installed."
          end
        '';
      }
    ];

    shellAbbrs =
      # tmux
      {
        tsd = "tmux switch-client -t dotfiles";
        tsw = "tmux switch-client -t work1";
        tsr = "tmux switch-client -t work2";
        ttd = "tmux a -t dotfiles";
        ttw = "tmux a -t work1";
        ttr = "tmux a -t work2";
      }
      # kubernetes
      // {
        k = "kubectl";
        kcu = "kubectl ctx -u";
        kc = "kubectl ctx";
      }
      # nix shortcuts
      // {
        nrp = "nix run nixpkgs#";
        nrs = "sudo nixos-rebuild switch --flake ~/.dotfiles/nix/";
        gc = "nix-collect-garbage --delete-old";
        jn = "justnix nix_rebuild";
        pos = "posix-source";
        t = "take";
        tt = "ttake";
        r = "refresh";
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

    shellAliases = lib.mkMerge [
      {
        vim = "nvim";
        vi = "nvim";
        ai = "aichat";
      }
      (lib.mkIf isWSL {
        xcopy = "xclip -selection clipboard";
        xpaste = "xclip -o -selection clipboard";
        explorer = "/mnt/c/Windows/explorer.exe";
      })
      (lib.mkIf isLinux {
        xcopy = "xclip -selection clipboard";
        xpaste = "xclip -o -selection clipboard";
      })
      (lib.mkIf isMac {
        xcopy = "pbcopy";
        xpaste = "pbpaste";
        explorer = "open";
      })
    ];

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
