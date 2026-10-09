{ config, lib, pkgs, ... }:

{
  programs.nushell = {
    enable = true;

    loginFile.source = ./login.nu;

    environmentVariables =
      lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin (
        lib.filterAttrs
          (name: _: name != "TERMINFO_DIRS")
          config.home.sessionVariables
      );

    extraEnv = ''
      $env.PATH = ${builtins.toJSON config.home.sessionPath}
        | append $env.PATH
        | flatten
        | uniq
    '';

    extraConfig = ''
      if ("~/.secrets.toml" | path exists) {
        "~/.secrets.toml" | open | load-env
      }

      def rebuild [] {
        let flake = "${config.home.homeDirectory}/.my-os-configs/nix"

        if (sys host | get name) == "Darwin" {
          sudo darwin-rebuild switch --flake $"($flake)#macbook"
        } else {
          nixos-rebuild switch --flake $"($flake)#(sys host | get hostname)" --sudo
        }
      }

      def upgrade [] {
        nix flake update --flake "${config.home.homeDirectory}/.my-os-configs/nix"
        rebuild
      }
    '';

    settings.show_banner = false;
  };
}
