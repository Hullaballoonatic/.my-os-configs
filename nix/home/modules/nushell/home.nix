{ config, ... }:

{
  programs.nushell = {
    enable = true;

    loginFile.source = ./login.nu;

    extraConfig = ''
      $env.PATH = ${builtins.toJSON config.home.sessionPath}
        | append $env.PATH
        | flatten
        | uniq

      source-env (if ("~/.secrets.nu" | path exists) { "~/.secrets.nu" } else { null }) 

      def rebuild [] {
        let flake = "${config.home.homeDirectory}/.my-os-configs/nix"

        if (sys host | get name) == "Darwin" {
          sudo darwin-rebuild switch --flake $"($flake)#macbook"
        } else {
          nixos-rebuild switch --flake $"($flake)#(sys host | get hostname)" --sudo
        }
      }
    '';

    settings.show_banner = false;
  };
}
