{
  description = "Casey's systems and packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    nixvim.url = "github:nix-community/nixvim";
    codex-nix.url = "github:SecBear/codex-nix";
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    home-pi-api.url = "github:Hullaballoonatic/home-pi-api";
    stylix.url = "github:danth/stylix";
    herdr.url = "github:ogulcancelik/herdr";
  };

  outputs = inputs @ {
    nixpkgs,
    self,
    stylix,
    ...
  }: let
    lib = nixpkgs.lib;

    hosts = {
      desktop = {
        system = "x86_64-linux";
      };

      pi = {
        system = "aarch64-linux";
      };
    };

    pkgsFor = system:
      import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

    makeSystem = hostname: let
      host = hosts.${hostname};
      username = "casey";
    in
      lib.nixosSystem {
        system = host.system;
        specialArgs = {inherit inputs self hostname username;};
        modules = [
          ./hosts/${hostname}/configuration.nix
          inputs.home-manager.nixosModules.home-manager

          {
            home-manager.useGlobalPkgs = true;

            home-manager.extraSpecialArgs = {
              inherit inputs hostname username;
            };

            home-manager.sharedModules = [
              stylix.homeModules.stylix
            ];

            home-manager.users.${username} = import ./hosts/${hostname}/home.nix;
          }
        ];
      };

    makeDarwinSystem = let
      system = "aarch64-darwin";
      hostname = "macbook";
      username = "CaseyStratton";
    in
      inputs.nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit inputs self hostname username;
        };
        modules = [
          ./hosts/macbook/configuration.nix
          inputs.home-manager.darwinModules.home-manager
          inputs.nix-homebrew.darwinModules.nix-homebrew

          {
            nix-homebrew = {
              enable = true;
              user = username;

              # Adopt the Homebrew installation that already exists at
              # /opt/homebrew instead of creating a second copy.
              autoMigrate = true;

              # Leave taps/formulae/casks that aren't declared below alone;
              # we're migrating Homebrew usage into Nix incrementally.
              mutableTaps = true;
            };
          }

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = {
              inherit inputs hostname username;
            };

            home-manager.sharedModules = [
              stylix.homeModules.stylix
            ];

            home-manager.users.${username} = {
              imports = [
                ./hosts/macbook/home.nix
              ];
            };
          }
        ];
      };
  in {
    nixosConfigurations = lib.mapAttrs (hostname: _: makeSystem hostname) hosts;

    darwinConfigurations.macbook = makeDarwinSystem;

    packages.aarch64-linux.home-pi-api = inputs.home-pi-api.packages.aarch64-linux.default;

    formatter = lib.mapAttrs (_: host: (pkgsFor host.system).alejandra) hosts;

    templates = {
      rust = {
        path = ./templates/rust;
        description = "Rust development environment";
      };
      python = {
        path = ./templates/python;
        description = "Python development environment";
      };
      web = {
        path = ./templates/web;
        description = "Web development environment";
      };
    };
  };
}
