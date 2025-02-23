set shell := ["bash", "-c"]

FLAKE := "~/.dotfiles/nix"

_default:
    @just --list

# Check Nix Flake syntax before rebuilding
nix_check:
    set -e
    echo "Checking Nix Flake syntax..."
    nix flake check {{FLAKE}} --show-trace
    echo "Nix Flake check passed!"
# Formats Nix files in the flake
nix_format:
    set -e
    echo "Formatting Nix files in {{FLAKE}}..."
    nixpkgs-fmt {{FLAKE}}
    echo "Nix files formatted successfully!"
# Rebuilds nix on the default host machine
nix_rebuild:
    @just _local
# Rebuilds nix on the specified host 'desktop-wsl-01'
nix_rebuild_wsl-01:
    @just _local_with_host desktop-wsl-01
# Rebuilds nix on the specified host 'desktop-wsl-02'
nix_rebuild_wsl-02:
    @just _local_with_host desktop-wsl-02
# Rebuilds nix on the remote machine 'px1-103' with target host: 'rus@192.168.1.103'
nix_rebuild_px1-103:
    @just _remote px1-103 rus@192.168.1.103
# Rebuilds nix on the remote machine 'px1-104' with target host: 'rus@192.168.1.104'
nix_rebuild_px1-104:
    @just _remote px1-104 rus@192.168.1.104
# Rebuilds nix on the remote machine 'px1-105' with target host: 'rus@192.168.1.105'
nix_rebuild_px1-105:
    @just _remote px1-105 rus@192.168.1.105
# Rebuilds nix on the remote machine 'px2-210' with target host: 'rus@192.168.1.210'
nix_rebuild_px2-210:
    @just _remote px2-210 rus@192.168.1.210
# Installs NixOS on the remote maching for first time
setup_nixos HOST TARGET_HOST:
  nix run github:nix-community/nixos-anywhere -- --flake {{FLAKE}}#{{HOST}} --target-host {{TARGET_HOST}}

_remote HOST TARGET_HOST:
    nixos-rebuild switch \
    --flake {{FLAKE}}#{{HOST}} \
    --fast \
    --build-host {{TARGET_HOST}} \
    --target-host {{TARGET_HOST}} \
    --use-remote-sudo

_local:
  sudo nixos-rebuild switch --flake {{FLAKE}}

_local_with_host HOST:
  sudo nixos-rebuild switch --flake {{FLAKE}}#{{HOST}}


