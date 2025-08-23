{
  description = "Dotfiles project dev shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
      forAllSystems = f:
        builtins.listToAttrs (map (system: {
          name = system;
          value = f system;
        }) systems);
    in {
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              just
              git
              sops
              age
              ansible
              ansible-lint
              nixpkgs-fmt
              stylua
              shellcheck
              shfmt
              yamllint
              markdownlint-cli2
              jq
            ];
            shellHook = ''
              export JUST_HIDE=1
              echo "Dev shell ready: just, sops, ansible, linting tools"
            '';
          };
        });
    };
}
