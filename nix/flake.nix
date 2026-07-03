{
  description = "Casey's Linux systems and packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    codex-nix.url = "github:SecBear/codex-nix";
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    vicinae.url = "github:vicinaehq/vicinae";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    home-pi-api.url = "github:Hullaballoonatic/home-pi-api";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      username = "casey";

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
          config.allowUnfree = true;
        };

      makeSystem = hostname:
        let
          host = hosts.${hostname};
        in
          lib.nixosSystem {
            system = host.system;
            specialArgs = { inherit inputs hostname username; };
            modules = [ 
              ./hosts/${hostname}/configuration.nix
              # inputs.home-manager.nixosModules.home-manager
            ];
          };

      makePackages = system: packageFile:
        let
          pkgs = pkgsFor system;
        in
          pkgs.buildEnv {
            name = "my-os-packages";
            paths = import packageFile { inherit pkgs; };
          };
    in {
      nixosConfigurations =
        lib.mapAttrs (hostname: _: makeSystem hostname) hosts;
      
      packages = {
        x86_64-linux.default = makePackages "x86_64-linux" ./packages/linux.nix;
        aarch64-linux = {
          default = makePackages "aarch64-linux" ./packages/linux.nix;
          home-pi-api = (pkgsFor "aarch64-linux").rustPlatform.buildRustPackage {
            pname = "home-pi-api";
            version = "0.1.0";
            src = inputs.home-pi-api;
            cargoLock.lockFile = "${inputs.home-pi-api}/Cargo.lock";
          };
        };
        aarch64-darwin.default = makePackages "aarch64-darwin.darwin" ./packages/darwin.nix;
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

