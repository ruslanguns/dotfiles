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
        ensure_all_packages_background = ''
          set lock_dir "/tmp/fish_packages_check.lock"
          set log_file "/tmp/fish_packages_check.log"

          if not mkdir "$lock_dir" >/dev/null 2>&1
            return 0 # Another check is already running, exit silently.
          end

          begin
            echo "🚀 Starting background package check at $(date '+%Y-%m-%d %H:%M:%S')"
            echo "---"

            type -q ensure_nodejs; and ensure_nodejs
            type -q ensure_npm_packages; and ensure_npm_packages
            type -q ensure_krew_plugins; and ensure_krew_plugins
            type -q ensure_rust_toolchain; and ensure_rust_toolchain
            type -q ensure_luarocks_packages; and ensure_luarocks_packages

            echo "---"
            echo "✅ Background package check finished at $(date '+%Y-%m-%d %H:%M:%S')"
          end > "$log_file"

          rmdir "$lock_dir"
        '';
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
        ensure_luarocks_packages = ''
          set required_packages \
            tiktoken_core

          set ignored_packages

          set installed_count 0
          set uninstalled_count 0

          if not type -q luarocks
              echo "❌ [luarocks] luarocks is not installed. Please install luarocks first."
              return 1
          end

          set -l current_value (luarocks config local_by_default | string trim)
          if test "$current_value" != "true"
              echo "🔧 [luarocks] setting local_by_default to true"
              luarocks config local_by_default true
          end

          for package in $required_packages
              if not luarocks list --porcelain | grep -q "^$package\s"
                  echo "📦 [luarocks] installing package: $package"
                  if luarocks install $package
                      set installed_count (math $installed_count + 1)
                  else
                      echo "❌ [luarocks] failed to install package: $package"
                  end
              end
          end

          set installed_packages (luarocks list --porcelain | cut -f1 | uniq)

          for package in $installed_packages
              if test -z "$package"
                  continue
              end
              if contains -- "$package" $required_packages || contains -- "$package" $ignored_packages
                  continue
              end

              echo "🗑️ [luarocks] uninstalling extraneous package: $package"
              if luarocks remove --force $package
                set uninstalled_count (math $uninstalled_count + 1)
              else
                echo "❌ [luarocks] failed to uninstall package: $package"
              end
          end

          if test $installed_count -gt 0
              echo "✅ [luarocks] $installed_count package(s) installed."
          end
          if test $uninstalled_count -gt 0
              echo "✅ [luarocks] $uninstalled_count extraneous package(s) uninstalled."
          end
        '';
        ensure_rust_toolchain = ''
          if not type -q rustup
            echo "❌ [rustup] rustup is not installed. Please install rustup first."
            return 1
          end

          if not rustup toolchain list | grep -q "stable"
            echo "📦 [rustup] installing stable toolchain"
            rustup toolchain install stable
          end

          if not rustup default | grep -q "stable"
            echo "🔧 [rustup] setting stable as default toolchain"
            rustup default stable
          end
        '';
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
        ensure_npm_packages = ''
          set required_packages \
            @google/gemini-cli \
            markdown-toc \
            @biomejs/biome

          set ignored_packages \
            npm \
            corepack

          set installed_count 0
          set uninstalled_count 0

          if not type -q npm
              echo "❌ [npm] npm is not installed. Please install Node.js first."
              return 1
          end

          for package in $required_packages
              if not npm list -g --depth=0 | grep -q "$package"
                  echo "📦 [npm] installing package: $package"
                  if npm install -g $package > /dev/null 2>&1
                      set installed_count (math $installed_count + 1)
                  else
                      echo "❌ [npm] failed to install package: $package"
                  end
              end
          end

          set installed_packages (npm list -g --depth=0 | grep -E '^[└├]' | sed -e 's/^.*── //' -e 's/ @[0-9][^ ]*$//' -e 's/@[0-9][^ ]*$//' | string trim)

          for package in $installed_packages
              if test -z "$package"
                  continue
              end
              if contains -- "$package" $required_packages || contains -- "$package" $ignored_packages
                  continue
              end

              echo "🗑️ [npm] uninstalling extraneous package: $package"
              if npm uninstall -g $package > /dev/null 2>&1
                set uninstalled_count (math $uninstalled_count + 1)
              else
                echo "❌ [npm] failed to uninstall package: $package"
              end
          end

          if test $installed_count -gt 0
              echo "✅ [npm] $installed_count package(s) installed."
          end
          if test $uninstalled_count -gt 0
              echo "✅ [npm] $uninstalled_count extraneous package(s) uninstalled."
          end
        '';
        ensure_krew_plugins = ''
          set required_plugins \
            krew \
            ns \
            ctx \
            foreach \
            apidocs \
            argo-apps-viz \
            cilium \
            count \
            ctr \
            df-pv \
            kyverno \
            kubescape \
            resource-capacity \
            stern \
            view-utilization \
            view-quotas \
            modify-secret \
            view-secret \
            unused-volumes

          set ignored_plugins \
            rise/accio-token

          set installed_count 0
          set uninstalled_count 0

          for plugin in $required_plugins
              if not krew list | grep -q "^$plugin"'$'
                  echo "📦 [krew] installing plugin: $plugin"
                  if krew install $plugin > /dev/null 2>&1
                      set installed_count (math $installed_count + 1)
                  else
                      echo "❌ [krew] failed to install plugin: $plugin"
                  end
              end
          end

          set installed_plugins (krew list)
          for plugin in $installed_plugins
              if test -z "$plugin"
                  continue
              end
              if contains -- "$plugin" $required_plugins || contains -- "$plugin" $ignored_plugins
                  continue
              end

              echo "🗑️ [krew] uninstalling extraneous plugin: $plugin"
              if krew uninstall $plugin > /dev/null 2>&1
                set uninstalled_count (math $uninstalled_count + 1)
              else
                echo "❌ [krew] failed to uninstall plugin: $plugin"
              end
          end

          if test $installed_count -gt 0
              echo "✅ [krew] $installed_count plugin(s) installed."
          end
          if test $uninstalled_count -gt 0
              echo "✅ [krew] $uninstalled_count extraneous plugin(s) uninstalled."
          end
        '';
        check_dns = ''
          set domain $argv[1]
          if test -z "$domain"
              echo "❌ Usage: check_dns <domain>"
              return 1
          end

          set output (nslookup $domain 2>&1)
          if echo $output | grep -q "can't find\|NXDOMAIN\|No answer"
              echo "❌ $domain"
          else
              echo "✅ $domain"
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
