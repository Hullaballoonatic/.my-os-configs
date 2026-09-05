{
  description = "Java development shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              jdk25
              maven
              jdt-language-server
              lombok
              google-java-format
            ];

            JAVA_HOME = "${pkgs.jdk25}"; # some tools (e.g. IDE plugins, gradle) expect this set explicitly
          };
        });
    };
}
