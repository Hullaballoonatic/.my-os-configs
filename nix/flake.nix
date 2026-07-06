{
  description = "Casey's systems and packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-nix.url = "github:SecBear/codex-nix";
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    home-pi-api.url = "github:Hullaballoonatic/home-pi-api";
  };

  outputs = inputs@{ nixpkgs, ... }:
    let
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
            permittedInsecurePackages = [
              "pnpm-10.29.2"
            ];
          };
        };

      makeSystem = hostname:
        let
          host = hosts.${hostname};
          username = "casey";
        in
          lib.nixosSystem {
            system = host.system;
            specialArgs = { inherit inputs hostname username; };
            modules = [
              ./hosts/${hostname}/configuration.nix
              inputs.home-manager.nixosModules.home-manager

              {
                home-manager.useGlobalPkgs = true;

                home-manager.extraSpecialArgs = {
                  inherit inputs hostname username;
                };

                home-manager.users.${username} = import ./hosts/${hostname}/home.nix;
              }
            ];
          };
    in {
      nixosConfigurations =
        lib.mapAttrs (hostname: _: makeSystem hostname) hosts;
     
      homeConfigurations."CaseyStratton" =
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor "aarch64-darwin";
          extraSpecialArgs = {
            inherit inputs;
            username = "CaseyStratton";
            hostname = "macbook";
          };
          modules = [
            ./home/darwin.nix
          ];
        };

      packages = {
        aarch64-linux = {
          home-pi-api = (pkgsFor "aarch64-linux").rustPlatform.buildRustPackage {
            pname = "home-pi-api";
            version = "0.1.0";
            src = inputs.home-pi-api;
            cargoLock.lockFile = "${inputs.home-pi-api}/Cargo.lock";
          };
        };
      };

      formatter =
        lib.mapAttrs (_: host: (pkgsFor host.system).alejandra) hosts;

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
