{
  pkgs,
  username,
  nix-index-database,
  win_user,
  ...
}:
let
  unstable-packages = with pkgs.unstable; [
    bat
    bottom
    coreutils
    curl
    du-dust
    fd
    findutils
    fx
    git
    git-crypt
    htop
    jq
    killall
    mosh
    procs
    ripgrep
    sd
    tree
    unzip
    vim
    wget
    zip
    k9s
    krew
    deno
    kubectl
    nixfmt-rfc-style
    neovim
    python3
    go
    bun
    kustomize
    kubecolor
    fzf
    lua51Packages.luarocks-nix
    lua51Packages.lua
    fnm
  ];

  stable-packages = with pkgs; [
    # productivity
    httpie # A user-friendly cURL replacement
    lazygit # A simple terminal UI for git commands
    pass
    kubeseal
    stern
    apacheHttpd
    sshpass

    # jeezyvim

    # key tools
    gh # for bootstrapping
    just

    # core languages
    rustup

    # rust stuff
    cargo-cache
    cargo-expand

    # local dev stuf
    mkcert
    httpie

    # treesitter
    tree-sitter

    # language servers
    nodePackages.vscode-langservers-extracted # html, css, json, eslint
    nodePackages.yaml-language-server
    nil # nix

    # formatters and linters
    alejandra # nix
    deadnix # nix
    nodePackages.prettier
    shellcheck
    shfmt
    statix # nix
    nixpkgs-fmt
    markdownlint-cli2
    sqlfluff
    stylua

    age.out
    ssh-to-age
    sops
    fluxcd
    kind
    speedtest-cli
    gdu
    lsof
    ltrace
    strace
    btop
    iftop

    # misc
    yq-go
    cowsay
    file
    which
    gnused
    gnutar
    gawk
    zstd
    gnupg
    gnumake

    # system
    glib
    gcc

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses
  ];
in
{
  imports = [
    nix-index-database.hmModules.nix-index
    ../../modules/zellij.nix
    ../../modules/starship.nix
    ../../modules/tmux.nix
  ];

  home.stateVersion = "22.11";

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables.EDITOR = "nvim";
    sessionVariables.SHELL = "/etc/profiles/per-user/${username}/bin/fish";
  };

  home.packages = stable-packages ++ unstable-packages;

  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    nix-index.enableFishIntegration = true;
    nix-index-database.comma.enable = true;

    # fzf.enable = true;
    fzf.enableFishIntegration = true;
    lsd.enable = true;
    lsd.enableAliases = true;
    zoxide.enable = true;
    zoxide.enableFishIntegration = true;
    zoxide.options = [ "--cmd cd" ];
    broot.enable = true;
    broot.enableFishIntegration = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    git = {
      enable = true;
      package = pkgs.unstable.git;
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
      userEmail = "ruslanguns@gmail.com";
      userName = "Ruslan Gonzalez";
      extraConfig = {
        # url = {
        #   "https://oauth2:${secrets.github_token}@github.com" = {
        #     insteadOf = "https://github.com";
        #   };
        #   "https://oauth2:${secrets.gitlab_token}@gitlab.com" = {
        #     insteadOf = "https://gitlab.com";
        #   };
        # };
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        merge = {
          conflictstyle = "diff3";
        };
        diff = {
          colorMoved = "default";
        };
      };
    };

    fish = {
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

        set gpg_id_file "/home/${username}/.env/gpg_id"
        set gpg_keys_file "/home/${username}/.env/gpg_keys"
        set password_store_dir "/home/${username}/.password-store"

        if test -e $gpg_id_file
            set gpg_id (cat $gpg_id_file | string trim)

            if test -e $gpg_keys_file
                gpg --list-secret-keys | grep -q "$gpg_id"
                if test $status -ne 0
                    gpg --import $gpg_keys_file
                end
            end

            if not test -e $password_store_dir/.gpg-id
                pass init $gpg_id
            end
        end

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
          kc = "kubectl ctx -u";
        }
        // {
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

  };

}
