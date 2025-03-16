{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nur.url = "github:nix-community/NUR";

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ld-rs = {
      url = "github:nix-community/nix-ld-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nur,
      nixpkgs-unstable,
      nix-index-database,
      disko,
      nixos-facter-modules,
      vscode-server,
      ...
    }@inputs:
    let
      variables = builtins.fromJSON (builtins.readFile "${self}/variables.json");

      config = {
        allowUnfree = true;
        permittedInsecurePackages = [ ];
      };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      nixpkgsWithOverlays =
        system:
        import nixpkgs {
          inherit system config;

          overlays = [
            nur.overlays.default
            (_final: _prev: {
              unstable = import nixpkgs-unstable {
                inherit system config;
              };
            })
          ];
        };

      configurationDefaults = args: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-backup";
        home-manager.extraSpecialArgs = args;
      };

      argDefaults = {
        inherit
          variables
          inputs
          self
          nix-index-database
          ;
        channels = {
          inherit nixpkgs nixpkgs-unstable;
        };
      };

      mkNixosConfiguration =
        {
          system ? "x86_64-linux",
          hostname ? "nixos",
          username ? "rus",
          win_user ? "Usuario",
          serverIp ? "",
          isWSL ? false,
          shell ? "fish",
          args ? { },
          modules,
        }:
        let
          specialArgs =
            argDefaults
            // {
              inherit
                hostname
                username
                isWSL
                shell
                serverIp
                win_user
                ;
            }
            // args;
        in
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          pkgs = nixpkgsWithOverlays system;
          modules = [
            (configurationDefaults specialArgs)
            home-manager.nixosModules.home-manager
          ] ++ modules;
        };
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      nixosConfigurations = {
        "generic" = mkNixosConfiguration {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/generic
          ];
        };

        "px1-103" = mkNixosConfiguration {
          system = "x86_64-linux";
          hostname = "px1-103";
          serverIp = "192.168.1.103";
          shell = "bash";
          modules = [
            disko.nixosModules.disko
            ./hosts/px-k8s-master
          ];
        };

        "px1-104" = mkNixosConfiguration {
          system = "x86_64-linux";
          hostname = "px1-104";
          serverIp = "192.168.1.103";
          shell = "bash";
          modules = [
            disko.nixosModules.disko
            ./hosts/px-k8s-node
          ];
        };

        "px1-105" = mkNixosConfiguration {
          system = "x86_64-linux";
          hostname = "px1-105";
          modules = [
            disko.nixosModules.disko
            ./hosts/px1-105
          ];
        };

        "px2-210" = mkNixosConfiguration {
          system = "x86_64-linux";
          hostname = "px2-210";
          serverIp = "192.168.1.103";
          modules = [
            disko.nixosModules.disko
            ./hosts/px-k8s-node
          ];
        };

        "px2-211" = mkNixosConfiguration {
          system = "x86_64-linux";
          hostname = "px2-211";
          serverIp = "192.168.1.103";
          modules = [
            disko.nixosModules.disko
            ./hosts/px-k8s-node
          ];
        };

        "desktop-wsl-01" = mkNixosConfiguration {
          hostname = "desktop-wsl-01";
          isWSL = true;
          modules = [
            inputs.nixos-wsl.nixosModules.wsl
            vscode-server.nixosModules.default
            ./hosts/desktop-wsl-01
          ];
        };

        "desktop-wsl-02" = mkNixosConfiguration {
          hostname = "desktop-wsl-02";
          isWSL = true;
          modules = [
            inputs.nixos-wsl.nixosModules.wsl
            ./hosts/desktop-wsl-02
          ];
        };
        "huawei-wsl-01" = mkNixosConfiguration {
          hostname = "huawei-wsl-01";
          isWSL = true;
          win_user = "Rus";
          modules = [
            inputs.nixos-wsl.nixosModules.wsl
            vscode-server.nixosModules.default
            ./hosts/huawei-wsl-01
          ];
        };
      };
    };
}
