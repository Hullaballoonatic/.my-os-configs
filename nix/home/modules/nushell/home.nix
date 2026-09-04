{ config, lib, ... }:

{
  programs.nushell = {
    enable = true;

    loginFile.source = ./login.nu;

    extraConfig = ''
      # `manage` is retired; rebuild directly via nix-darwin/NixOS per host.
      def rebuild [] {
        if (sys host | get name) == "Darwin" {
          sudo darwin-rebuild switch --flake ~/.my-os-configs/nix#macbook
        } else {
          nixos-rebuild switch --flake $"~/.my-os-configs/nix#(sys host | get hostname)" --sudo
        }
      }
    '';

    # nushell doesn't source the POSIX hm-session-vars.sh Home Manager
    # normally generates from `home.sessionPath` (that's a bash/zsh-only
    # mechanism), so we rebuild $env.PATH from it here. This makes PATH
    # self-healing every session, regardless of what minimal PATH the
    # launching process (e.g. a terminal emulator on macOS) handed us.
    extraEnv = ''
      ${lib.concatMapStrings (dir: "$env.PATH = ($env.PATH | prepend \"${dir}\")\n") (lib.reverseList config.home.sessionPath)}
      $env.PATH = ($env.PATH | uniq)

      source-env (if ("~/.secrets.nu" | path exists) { "~/.secrets.nu" } else { null }) 
    '';

    settings.show_banner = false;
  };
}
