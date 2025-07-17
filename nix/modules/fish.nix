{
  pkgs,
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

      set dotfiles_script_path "$HOME/.dotfiles/scripts"
      if test -d $dotfiles_script_path
        set -gx PATH $PATH $dotfiles_script_path
        chmod +x $dotfiles_script_path/*
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

      # argc based script completion
      argc --argc-completions fish oauth2 | source

      function run_package_check_once --on-event fish_prompt
          if not set -q __fish_package_check_started
              set -g __fish_package_check_started
              fish -c "ensure_all_packages_background" &; disown
          end
          functions --erase run_package_check_once
      end
    '';
    functions = lib.mkMerge [
      {
        # Orchestrator function that handles shell context
        ensure_all_packages_background = ''
          set lock_dir "/tmp/fish_packages_check.lock"
          set log_file "/tmp/fish_packages_check.log"

          if not mkdir "$lock_dir" >/dev/null 2>&1
            return 0 # Another check is already running, exit silently.
          end

          # Use a subshell to redirect all output to the log file
          begin
            echo "🚀 Starting background package check at $(date '+%Y-%m-%d %H:%M:%S')"
            echo "---"

            # Step 1: Ensure Node.js version is installed via the bash script
            command -v ensure-nodejs &> /dev/null; and ensure-nodejs

            # Step 2: IMPORTANT - Source fnm into the CURRENT fish context
            # This makes 'npm' available for subsequent scripts.
            if command -v fnm &> /dev/null
              fnm env | source
            end

            # Step 3: Now run the other scripts that depend on the context
            command -v ensure-npm-packages &> /dev/null; and ensure-npm-packages
            command -v ensure-krew-plugins &> /dev/null; and ensure-krew-plugins
            command -v ensure-rust-toolchain &> /dev/null; and ensure-rust-toolchain
            command -v ensure-luarocks-packages &> /dev/null; and ensure-luarocks-packages

            echo "---"
            echo "✅ Background package check finished at $(date '+%Y-%m-%d %H:%M:%S')"
          end > "$log_file" 2>&1

          rmdir "$lock_dir"
        '';

        # Utility functions that MUST remain as fish functions
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