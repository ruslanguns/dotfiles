{
  description = "Flakes configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    };

  };

  outputs = inputs@{ nixpkgs, home-manager, hyprland, ... }: {
   # homeConfigurations = {
   #   nixos = home-manager.lib.homeManagerConfiguration {
   #     pkgs = nixpkgs.legacyPackages.x86_64-linux;

   #     modules = [
   #       hyprland.homeManagerModules.default
   #       {wayland.windowManager.hyprland.enable = true;}
   #     ];
   #   };
   # };
   #
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
             home-manager.useGlobalPkgs = true;
             home-manager.useUserPackages = true;
             home-manager.users.rus = import ./home.nix;
          }
          #./hyprland.nix
	      ];
      };
    };
  };
}
