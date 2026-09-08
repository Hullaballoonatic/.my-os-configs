{ config, lib, ... }:

{
  programs.nushell = {
    enable = true;

    loginFile.source = ./login.nu;

    environmentVariables =
      # Nushell doesn't source the POSIX hm-session-vars.sh Home Manager
      # normally generates from home.sessionVariables. Forward them through
      # Home Manager's native Nushell option instead. TERMINFO_DIRS is
      # excluded because Home Manager sets it using POSIX self-reference
      # syntax ($TERMINFO_DIRS''${TERMINFO_DIRS:+:}...) that is not a valid
      # Nushell value.
      lib.filterAttrs (name: _: name != "TERMINFO_DIRS") config.home.sessionVariables;

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
